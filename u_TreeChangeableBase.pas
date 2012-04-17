{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2012, SAS.Planet development team.                      *}
{* This program is free software: you can redistribute it and/or modify       *}
{* it under the terms of the GNU General Public License as published by       *}
{* the Free Software Foundation, either version 3 of the License, or          *}
{* (at your option) any later version.                                        *}
{*                                                                            *}
{* This program is distributed in the hope that it will be useful,            *}
{* but WITHOUT ANY WARRANTY; without even the implied warranty of             *}
{* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *}
{* GNU General Public License for more details.                               *}
{*                                                                            *}
{* You should have received a copy of the GNU General Public License          *}
{* along with this program.  If not, see <http://www.gnu.org/licenses/>.      *}
{*                                                                            *}
{* http://sasgis.ru                                                           *}
{* az@sasgis.ru                                                               *}
{******************************************************************************}

unit u_TreeChangeableBase;

interface

uses
  SysUtils,
  i_JclNotify,
  i_StaticTreeItem,
  i_StaticTreeBuilder,
  i_TreeChangeable;

type
  TTreeChangeableBase = class(TInterfacedObject, ITreeChangeable)
  private
    FStaticTreeBuilder: IStaticTreeBuilder;
    FConfigChangeListener: IJclListener;
    FConfigChangeNotifier: IJclNotifier;
    FChangeNotifier: IJclNotifier;
    FCS: IReadWriteSync;

    FStatic: IStaticTreeItem;
    procedure OnConfigChange;
  protected
    function CreateStatic: IStaticTreeItem;
    function GetSource: IInterface; virtual; abstract;
  protected
    function GetStatic: IStaticTreeItem;
    function GetChangeNotifier: IJclNotifier;
  public
    constructor Create(
      const AStaticTreeBuilder: IStaticTreeBuilder;
      const AConfigChangeNotifier: IJclNotifier
    );
    destructor Destroy; override;
  end;

implementation

uses
  u_Synchronizer,
  u_JclNotify,
  u_NotifyEventListener;

{ TTreeChangeableBase }

constructor TTreeChangeableBase.Create(
  const AStaticTreeBuilder: IStaticTreeBuilder;
  const AConfigChangeNotifier: IJclNotifier
);
begin
  inherited Create;
  FStaticTreeBuilder := AStaticTreeBuilder;
  FConfigChangeNotifier := AConfigChangeNotifier;
  FChangeNotifier := TJclBaseNotifier.Create;
  FCS := MakeSyncRW_Var(Self);
  FConfigChangeListener := TNotifyNoMmgEventListener.Create(Self.OnConfigChange);
  FConfigChangeNotifier.Add(FConfigChangeListener);
  OnConfigChange;
end;

destructor TTreeChangeableBase.Destroy;
begin
  FConfigChangeNotifier.Remove(FConfigChangeListener);
  FConfigChangeListener := nil;
  FConfigChangeNotifier := nil;

  FCS := nil;

  inherited;
end;

function TTreeChangeableBase.CreateStatic: IStaticTreeItem;
begin
  Result := FStaticTreeBuilder.BuildStatic(GetSource);
end;

function TTreeChangeableBase.GetChangeNotifier: IJclNotifier;
begin
  Result := FChangeNotifier;
end;

function TTreeChangeableBase.GetStatic: IStaticTreeItem;
begin
  FCS.BeginRead;
  try
    Result := FStatic;
  finally
    FCS.EndRead;
  end;
end;

procedure TTreeChangeableBase.OnConfigChange;
var
  VStatic: IStaticTreeItem;
begin
  VStatic := CreateStatic;
  FCS.BeginWrite;
  try
    FStatic := VStatic;
  finally
    FCS.EndWrite;
  end;
  FChangeNotifier.Notify(nil);
end;

end.
