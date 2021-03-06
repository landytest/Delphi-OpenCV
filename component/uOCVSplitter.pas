// *****************************************************************
// Delphi-OpenCV Demo
// Copyright (C) 2013 Project Delphi-OpenCV
// ****************************************************************
// Contributor:
// Laentir Valetov
// email:laex@bk.ru
// ****************************************************************
// You may retrieve the latest version of this file at the GitHub,
// located at git://github.com/Laex/Delphi-OpenCV.git
// ****************************************************************
// The contents of this file are used with permission, subject to
// the Mozilla Public License Version 1.1 (the "License"); you may
// not use this file except in compliance with the License. You may
// obtain a copy of the License at
// http://www.mozilla.org/MPL/MPL-1_1Final.html
//
// Software distributed under the License is distributed on an
// "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
// implied. See the License for the specific language governing
// rights and limitations under the License.
// *******************************************************************
unit uOCVSplitter;

interface

Uses
  System.Classes,
  core.types_c,
  uOCVTypes;

Type
  TocvChannel = class(TCollectionItem, IocvDataSource)
  private
    FOpenCVVideoReceiver: IocvDataReceiver;
    FVCLComObject: Pointer;
    FDataReceiver: TocvDataReceiver;
    FName: String;
  protected
    procedure SetReceiver(const OpenCVVideoReceiver: IocvDataReceiver);
    procedure NotifyReceiver(const IplImage: pIplImage);
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  published
    property Name: String read FName write FName;
  end;

  TocvChannelCollection = class(TCollection)
  private
    function GetOCVItem(Index: Integer): IocvDataSource;
  public
    property OCVChannel[Index: Integer]: IocvDataSource read GetOCVItem; default;
  end;

  TocvSplitter = class(TocvDataReceiver)
  private
    FChannels: TocvChannelCollection;
    FocvVideoSource: TocvDataSource;
    procedure SetOpenCVVideoSource(const Value: TocvDataSource);
    procedure SetChannels(const Value: TocvChannelCollection);
  protected
    procedure TakeImage(const IplImage: pIplImage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property VideoSource: TocvDataSource Read FocvVideoSource write SetOpenCVVideoSource;
    property Channels: TocvChannelCollection read FChannels write SetChannels;
  end;

implementation

{ TocvSplitter }

constructor TocvSplitter.Create(AOwner: TComponent);
begin
  inherited;
  FChannels := TocvChannelCollection.Create(TocvChannel);
end;

destructor TocvSplitter.Destroy;
begin
  FChannels.Free;
  inherited;
end;

procedure TocvSplitter.SetChannels(const Value: TocvChannelCollection);
begin
  FChannels.Assign(Value);
end;

procedure TocvSplitter.SetOpenCVVideoSource(const Value: TocvDataSource);
begin
  if FocvVideoSource <> Value then
  begin
    if Assigned(FocvVideoSource) then
      FocvVideoSource.SetReceiver(nil);
    FocvVideoSource := Value;
    if Assigned(FocvVideoSource) then
      FocvVideoSource.SetReceiver(Self);
  end;
end;

procedure TocvSplitter.TakeImage(const IplImage: pIplImage);
var
  OCVChannel: TCollectionItem;
begin
  for OCVChannel in FChannels do
    (OCVChannel as TocvChannel).NotifyReceiver(IplImage);
end;

{ TocvChannel }

procedure TocvChannel.NotifyReceiver(const IplImage: pIplImage);
begin
  if Assigned(FOpenCVVideoReceiver) then
    FOpenCVVideoReceiver.TakeImage(IplImage);
end;

function TocvChannel.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if FVCLComObject = nil then
  begin
    if GetInterface(IID, Obj) then
      Result := S_OK
    else
      Result := E_NOINTERFACE
  end
  else
    Result := IVCLComObject(FVCLComObject).QueryInterface(IID, Obj);
end;

procedure TocvChannel.SetReceiver(const OpenCVVideoReceiver: IocvDataReceiver);
begin
  FOpenCVVideoReceiver := OpenCVVideoReceiver;
end;

function TocvChannel._AddRef: Integer;
begin
  if FVCLComObject = nil then
    Result := -1 // -1 indicates no reference counting is taking place
  else
    Result := IVCLComObject(FVCLComObject)._AddRef;
end;

function TocvChannel._Release: Integer;
begin
  if FVCLComObject = nil then
    Result := -1 // -1 indicates no reference counting is taking place
  else
    Result := IVCLComObject(FVCLComObject)._Release;
end;

{ TocvChannelCollection }

function TocvChannelCollection.GetOCVItem(Index: Integer): IocvDataSource;
begin
  Result := TocvChannel(inherited GetItem(Index));
end;

end.
