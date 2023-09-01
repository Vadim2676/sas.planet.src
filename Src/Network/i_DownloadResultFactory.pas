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

unit i_DownloadResultFactory;

interface

uses
  Types,
  i_BinaryData,
  i_DownloadRequest,
  i_DownloadResult;

type
  IDownloadResultFactory = interface
    ['{672345FB-40BA-4B13-AADE-6771192478FD}']
    function BuildCanceled(
      const ARequest: IDownloadRequest
    ): IDownloadResultCanceled;

    function BuildOk(
      const ARequest: IDownloadRequest;
      const AStatusCode: Cardinal;
      const ARawResponseHeader: AnsiString;
      const AContentType: AnsiString;
      const AData: IBinaryData
    ): IDownloadResultOk;

    function BuildUnexpectedProxyAuth(
      const ARequest: IDownloadRequest
    ): IDownloadResultProxyError;

    function BuildBadProxyAuth(
      const ARequest: IDownloadRequest
    ): IDownloadResultProxyError;

    function BuildNoConnetctToServerByErrorCode(
      const ARequest: IDownloadRequest;
      const AErrorCode: DWORD
    ): IDownloadResultNoConnetctToServer;

    function BuildLoadErrorByStatusCode(
      const ARequest: IDownloadRequest;
      const AStatusCode: DWORD
    ): IDownloadResultError;

    function BuildLoadErrorByUnknownStatusCode(
      const ARequest: IDownloadRequest;
      const AStatusCode: DWORD
    ): IDownloadResultError;

    function BuildLoadErrorByErrorCode(
      const ARequest: IDownloadRequest;
      const AErrorCode: DWORD
    ): IDownloadResultError;

    function BuildLoadErrorByUnknownReason(
      const ARequest: IDownloadRequest;
      const AReasonTextFormat: string;
      const AReasonTextArgs: array of const
    ): IDownloadResultError;

    function BuildBadContentType(
      const ARequest: IDownloadRequest;
      const AContentType: AnsiString;
      const AStatusCode: DWORD;
      const ARawResponseHeader: AnsiString
    ): IDownloadResultBadContentType;

    function BuildBadContentEncoding(
      const ARequest: IDownloadRequest;
      const AStatusCode: Cardinal;
      const ARawResponseHeader: AnsiString;
      const AContentEncoding: AnsiString;
      const AData: IBinaryData;
      const AErrorTextFormat: string;
      const AErrorTextArgs: array of const
    ): IDownloadResultBadContentEncoding;

    function BuildBanned(
      const ARequest: IDownloadRequest;
      const AStatusCode: DWORD;
      const ARawResponseHeader: AnsiString
    ): IDownloadResultBanned;

    function BuildDataNotExists(
      const ARequest: IDownloadRequest;
      const AReasonTextFormat: string;
      const AReasonTextArgs: array of const;
      const AStatusCode: DWORD;
      const ARawResponseHeader: AnsiString
    ): IDownloadResultDataNotExists;

    function BuildDataNotExistsByStatusCode(
      const ARequest: IDownloadRequest;
      const ARawResponseHeader: AnsiString;
      const AStatusCode: DWORD
    ): IDownloadResultDataNotExists;

    function BuildDataNotExistsZeroSize(
      const ARequest: IDownloadRequest;
      const AStatusCode: DWORD;
      const ARawResponseHeader: AnsiString
    ): IDownloadResultDataNotExists;

    function BuildNotNecessary(
      const ARequest: IDownloadRequest;
      const AReasonTextFormat: string;
      const AReasonTextArgs: array of const;
      const AStatusCode: DWORD;
      const ARawResponseHeader: AnsiString
    ): IDownloadResultNotNecessary;
  end;

implementation

end.
