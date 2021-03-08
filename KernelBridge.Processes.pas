unit KernelBridge.Processes;

interface

uses
  Winapi.WinNt, Ntapi.ntdef, Ntapi.ntpsapi, kbapi, NtUtils;

{ ------------------------------- Descriptors ------------------------------- }

// Determine the address of EPROCESS structure for a process
function KbxGetEprocess(
  out eProcess: IMemory;
  ProcessId: TProcessId32
): TNtxStatus;

// Determine the address of ETHREAD structure for a process
function KbxGetEthread(
  out eThread: IMemory;
  ThreadId: TThreadId32
): TNtxStatus;

// Open a process by ID
function KbxOpenProcess(
  out hxProcess: IHandle;
  ProcessId: TProcessId32;
  Access: TProcessAccessMask;
  Attributes: TObjectAttributesFlags = 0
): TNtxStatus;

// Open a process by a pointer to EPROCESS
function KbxOpenProcessByPointer(
  out hxProcess: IHandle;
  Address: PEProcess;
  Access: TProcessAccessMask;
  Attributes: TObjectAttributesFlags = 0;
  ProcessorMode: TProcessorMode = KernelMode
): TNtxStatus;

// Open a thread by ID
function KbxOpenThread(
  out hxThread: IHandle;
  ThreadId: TProcessId32;
  Access: TThreadAccessMask;
  Attributes: TObjectAttributesFlags = 0
): TNtxStatus;

// Open a thread by a pointer to ETHREAD
function KbxOpenThreadByPointer(
  out hxThread: IHandle;
  Address: PEThread;
  Access: TThreadAccessMask;
  Attributes: TObjectAttributesFlags = 0;
  ProcessorMode: TProcessorMode = KernelMode
): TNtxStatus;

implementation

uses
  DelphiUtils.AutoObject;

{ Descriptors }

type
  TKbAutoObject = class (TCustomAutoMemory, IMemory)
    destructor Destroy; override;
  end;

  TKbAutoHandle = class (TCustomAutoHandle, IHandle)
    destructor Destroy; override;
  end;

destructor TKbAutoObject.Destroy;
begin
  if FAutoRelease then
    KbDereferenceObject(FAddress);

  inherited;
end;

destructor TKbAutoHandle.Destroy;
begin
  if FAutoRelease then
    KbCloseHandle(FHandle);

  inherited;
end;

function KbxGetEprocess;
var
  Address: PEProcess;
begin
  Result.Location := 'KbGetEprocess';
  Result.Win32Result := KbGetEprocess(ProcessId, Address);

  if Result.IsSuccess then
    eProcess := TKbAutoObject.Capture(Address, 0);
end;

function KbxGetEthread;
var
  Address: PEThread;
begin
  Result.Location := 'KbGetEthread';
  Result.Win32Result := KbGetEthread(ThreadId, Address);

  if Result.IsSuccess then
    eThread := TKbAutoObject.Capture(Address, 0);
end;

function KbxOpenProcess;
var
  hProcess: THandle;
begin
  Result.Location := 'KbOpenProcess';
  Result.LastCall.AttachAccess<TProcessAccessMask>(Access);
  Result.Win32Result := KbOpenProcess(ProcessId, hProcess, Access, Attributes);

  if Result.IsSuccess then
    hxProcess := TKbAutoHandle.Capture(hProcess);
end;

function KbxOpenProcessByPointer;
var
  hProcess: THandle;
begin
  Result.Location := 'KbOpenProcessByPointer';
  Result.LastCall.AttachAccess<TProcessAccessMask>(Access);
  Result.Win32Result := KbOpenProcessByPointer(Address, hProcess, Access,
    Attributes, ProcessorMode);

  if Result.IsSuccess then
    hxProcess := TKbAutoHandle.Capture(hProcess);
end;

function KbxOpenThread;
var
  hThread: THandle;
begin
  Result.Location := 'KbOpenThread';
  Result.LastCall.AttachAccess<TThreadAccessMask>(Access);
  Result.Win32Result := KbOpenThread(ThreadId, hThread, Access, Attributes);

  if Result.IsSuccess then
    hxThread := TKbAutoHandle.Capture(hThread);
end;

function KbxOpenThreadByPointer;
var
  hThread: THandle;
begin
  Result.Location := 'KbOpenThreadByPointer';
  Result.LastCall.AttachAccess<TThreadAccessMask>(Access);
  Result.Win32Result := KbOpenThreadByPointer(Address, hThread, Access,
    Attributes, ProcessorMode);

  if Result.IsSuccess then
    hxThread := TKbAutoHandle.Capture(hThread);
end;


end.