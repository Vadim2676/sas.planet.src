{******************************************************************************}
{* This file is part of SAS.Planet project.                                   *}
{*                                                                            *}
{* Copyright (C) 2007-2022, SAS.Planet development team.                      *}
{*                                                                            *}
{* SAS.Planet is free software: you can redistribute it and/or modify         *}
{* it under the terms of the GNU General Public License as published by       *}
{* the Free Software Foundation, either version 3 of the License, or          *}
{* (at your option) any later version.                                        *}
{*                                                                            *}
{* SAS.Planet is distributed in the hope that it will be useful,              *}
{* but WITHOUT ANY WARRANTY; without even the implied warranty of             *}
{* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the               *}
{* GNU General Public License for more details.                               *}
{*                                                                            *}
{* You should have received a copy of the GNU General Public License          *}
{* along with SAS.Planet. If not, see <http://www.gnu.org/licenses/>.         *}
{*                                                                            *}
{* https://github.com/sasgis/sas.planet.src                                   *}
{******************************************************************************}

unit u_IeEmbeddedProtocolRegistration;

interface

uses
  UrlMon,
  {$IFNDEF UNICODE}
  Compatibility,
  {$ENDIF}
  ActiveX;

type
  TIeEmbeddedProtocolRegistration = class
  private
    FProtocol: UnicodeString;
    FFactory: IClassFactory;
    FInternetSession: IInternetSession;
  public
    constructor Create(
      const AProtocol: PWideChar;
      const AFactory: IClassFactory
    );
    destructor Destroy; override;
  end;

implementation

const
  CIEEmbeddedProtocol_Class: TGUID = '{A9CA884C-253A-4662-A4F6-6926BAB877F9}';

{ TIeEmbeddedProtocolRegistration }

constructor TIeEmbeddedProtocolRegistration.Create(
  const AProtocol: PWideChar;
  const AFactory: IClassFactory
);
begin
  inherited Create;
  FProtocol := AProtocol;
  FFactory := AFactory;
  CoInternetGetSession(0, FInternetSession, 0);
  FInternetSession.RegisterNameSpace(FFactory, CIEEmbeddedProtocol_Class, PWideChar(FProtocol), 0, nil, 0);
end;

destructor TIeEmbeddedProtocolRegistration.Destroy;
begin
  if Assigned(FInternetSession) then begin
    FInternetSession.UnregisterNameSpace(FFactory, PWideChar(FProtocol));
  end;
  FFactory := nil;
  FInternetSession := nil;
  inherited;
end;

end.
