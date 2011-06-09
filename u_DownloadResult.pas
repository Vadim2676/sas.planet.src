unit u_DownloadResult;

interface

uses
  Types,
  Classes,
  i_DownloadResult;

type
  TDownloadResult = class(TInterfacedObject, IDownloadResult)
  private
    FUrl: string;
    FRequestHead: string;
  protected
    function GetUrl: string;
    function GetRequestHead: string;
    function GetIsOk: Boolean; virtual; abstract;
    function GetIsServerExists: Boolean; virtual; abstract;
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string
    );
  end;

  TDownloadResultOk = class(TDownloadResult, IDownloadResultOk)
  private
    FStatusCode: Cardinal;
    FRawResponseHeader: string;
    FContentType: string;
    FBuffer: TMemoryStream;
  protected
    function GetIsOk: Boolean; override;
    function GetIsServerExists: Boolean; override;
  protected
    function GetStatusCode: Cardinal;
    function GetRawResponseHeader: string;
    function GetContentType: string;
    function GetSize: Integer;
    function GetBuffer: Pointer;
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AStatusCode: Cardinal;
      ARawResponseHeader: string;
      AContentType: string;
      ASize: Integer;
      ABuffer: Pointer
    );
    destructor Destroy; override;
  end;

  TDownloadResultError = class(TDownloadResult, IDownloadResultError)
  private
    FErrorText: string;
  protected
    function GetIsOk: Boolean; override;
  protected
    function GetErrorText: string;
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AErrorText: string
    );
  end;

  TDownloadResultProxyError = class(TDownloadResultError, IDownloadResultProxyError)
  protected
    function GetIsServerExists: Boolean; override;
  end;

  TDownloadResultUnexpectedProxyAuth = class(TDownloadResultProxyError)
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string
    );
  end;

  TDownloadResultBadProxyAuth = class(TDownloadResultProxyError)
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string
    );
  end;

  TDownloadResultNoConnetctToServer = class(TDownloadResultError, IDownloadResultNoConnetctToServer)
  protected
    function GetIsServerExists: Boolean; override;
  end;

  TDownloadResultNoConnetctToServerByErrorCode = class(TDownloadResultNoConnetctToServer)
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AErrorCode: DWORD
    );
  end;

  TDownloadResultLoadError = class(TDownloadResultError)
  protected
    function GetIsServerExists: Boolean; override;
  end;

  TDownloadResultLoadErrorByStatusCode = class(TDownloadResultLoadError)
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AStatusCode: DWORD
    );
  end;

  TDownloadResultLoadErrorByUnknownStatusCode = class(TDownloadResultLoadError)
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AStatusCode: DWORD
    );
  end;

  TDownloadResultLoadErrorByErrorCode = class(TDownloadResultLoadError)
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AErrorCode: DWORD
    );
  end;

  TDownloadResultBanned = class(TDownloadResultError, IDownloadResultBanned)
  protected
    function GetIsServerExists: Boolean; override;
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string
    );
  end;

  TDownloadResultBadContentType = class(TDownloadResultError, IDownloadResultBadContentType)
  protected
    function GetIsServerExists: Boolean; override;
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AContentType: string
    );
  end;

  TDownloadResultDataNotExists = class(TDownloadResult, IDownloadResultDataNotExists)
  private
    FReasonText: string;
  protected
    function GetIsOk: Boolean; override;
    function GetIsServerExists: Boolean; override;
  protected
    function GetReasonText: string;
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AReasonText: string
    );
  end;

  TDownloadResultDataNotExistsByStatusCode = class(TDownloadResultDataNotExists)
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AStatusCode: DWORD
    );
  end;

  TDownloadResultDataNotExistsZeroSize = class(TDownloadResultDataNotExists)
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string
    );
  end;

  TDownloadResultNotNecessary = class(TDownloadResult, IDownloadResultNotNecessary)
  private
    FReasonText: string;
  protected
    function GetIsOk: Boolean; override;
    function GetIsServerExists: Boolean; override;
  protected
    function GetReasonText: string;
  public
    constructor Create(
      AUrl: string;
      ARequestHead: string;
      AReasonText: string
    );
  end;

implementation

uses
  SysUtils;

{ TDownloadResult }

constructor TDownloadResult.Create(AUrl, ARequestHead: string);
begin
  FUrl := AUrl;
  FRequestHead := ARequestHead;
end;

function TDownloadResult.GetRequestHead: string;
begin
  Result := FRequestHead;
end;

function TDownloadResult.GetUrl: string;
begin
  Result := FUrl;
end;

{ TDownloadResultOk }

constructor TDownloadResultOk.Create(AUrl, ARequestHead: string;
  AStatusCode: Cardinal; ARawResponseHeader, AContentType: string;
  ASize: Integer;
  ABuffer: Pointer
);
begin
  inherited Create(AUrl, ARequestHead);
  FStatusCode := AStatusCode;
  FRawResponseHeader := ARawResponseHeader;
  FContentType := AContentType;
  FBuffer := TMemoryStream.Create;
  FBuffer.WriteBuffer(ABuffer^, ASize);
end;

destructor TDownloadResultOk.Destroy;
begin
  FreeAndNil(FBuffer);
  inherited;
end;

function TDownloadResultOk.GetBuffer: Pointer;
begin
  Result := FBuffer.Memory;
end;

function TDownloadResultOk.GetContentType: string;
begin
  Result := FContentType;
end;

function TDownloadResultOk.GetIsOk: Boolean;
begin
  Result := True;
end;

function TDownloadResultOk.GetIsServerExists: Boolean;
begin
  Result := True;
end;

function TDownloadResultOk.GetRawResponseHeader: string;
begin
  Result := FRawResponseHeader;
end;

function TDownloadResultOk.GetSize: Integer;
begin
  Result := FBuffer.Size;
end;

function TDownloadResultOk.GetStatusCode: Cardinal;
begin
  Result := FStatusCode;
end;

{ TDownloadResultError }

constructor TDownloadResultError.Create(AUrl, ARequestHead, AErrorText: string);
begin
  inherited Create(AUrl, ARequestHead);
  FErrorText := AErrorText;
end;

function TDownloadResultError.GetErrorText: string;
begin
  Result := FErrorText;
end;

function TDownloadResultError.GetIsOk: Boolean;
begin
  Result := False;
end;

{ TDownloadResultProxyError }

function TDownloadResultProxyError.GetIsServerExists: Boolean;
begin
  Result := False;
end;

{ TDownloadResultNoConnetctToServer }

function TDownloadResultNoConnetctToServer.GetIsServerExists: Boolean;
begin
  Result := False;
end;

{ TDownloadResultBanned }

constructor TDownloadResultBanned.Create(AUrl, ARequestHead: string);
begin
  inherited Create(AUrl, ARequestHead, '������ ��� ��������');
end;

function TDownloadResultBanned.GetIsServerExists: Boolean;
begin
  Result := True;
end;

{ TDownloadResultBadContentType }

constructor TDownloadResultBadContentType.Create(AUrl, ARequestHead,
  AContentType: string);
begin
  inherited Create(AUrl, ARequestHead, Format('����������� ��� %s', [AContentType]));
end;

function TDownloadResultBadContentType.GetIsServerExists: Boolean;
begin
  Result := True;
end;

{ TDownloadResultUnexpectedProxyAuth }

constructor TDownloadResultUnexpectedProxyAuth.Create(AUrl,
  ARequestHead: string);
begin
  inherited Create(AUrl, ARequestHead, '��������� �� ��������������� ����������� �� ������');
end;

{ TDownloadResultBadProxyAuth }

constructor TDownloadResultBadProxyAuth.Create(AUrl, ARequestHead: string);
begin
  inherited Create(AUrl, ARequestHead, '������ ����������� �� ������');
end;

{ TDownloadResultNoConnetctToServerByErrorCode }

constructor TDownloadResultNoConnetctToServerByErrorCode.Create(AUrl,
  ARequestHead: string; AErrorCode: DWORD);
begin
  inherited Create(AUrl, ARequestHead, Format('������ ����������� � �������. ��� ������ %d', [AErrorCode]));
end;

{ TDownloadResultLoadErrorByStatusCode }

constructor TDownloadResultLoadErrorByStatusCode.Create(AUrl,
  ARequestHead: string; AStatusCode: DWORD);
begin
  inherited Create(AUrl, ARequestHead, Format('������ ��������. ������ %d', [AStatusCode]));
end;

{ TDownloadResultLoadErrorByErrorCode }

constructor TDownloadResultLoadErrorByErrorCode.Create(AUrl,
  ARequestHead: string; AErrorCode: DWORD);
begin
  inherited Create(AUrl, ARequestHead, Format('������ ��������. ��� ������ %d', [AErrorCode]));
end;

{ TDownloadResultLoadError }

function TDownloadResultLoadError.GetIsServerExists: Boolean;
begin
  Result := True;
end;

{ TIDownloadResultDataNotExists }

constructor TDownloadResultDataNotExists.Create(AUrl, ARequestHead,
  AReasonText: string);
begin
  inherited Create(AUrl, ARequestHead);
  FReasonText := AReasonText;
end;

function TDownloadResultDataNotExists.GetIsOk: Boolean;
begin
  Result := True;
end;

function TDownloadResultDataNotExists.GetIsServerExists: Boolean;
begin
  Result := True;
end;

function TDownloadResultDataNotExists.GetReasonText: string;
begin
  Result := FReasonText;
end;

{ TDownloadResultNotNecessary }

constructor TDownloadResultNotNecessary.Create(AUrl, ARequestHead,
  AReasonText: string);
begin
  inherited Create(AUrl, ARequestHead);
  FReasonText := AReasonText;
end;

function TDownloadResultNotNecessary.GetIsOk: Boolean;
begin
  Result := True;
end;

function TDownloadResultNotNecessary.GetIsServerExists: Boolean;
begin
  Result := True;
end;

function TDownloadResultNotNecessary.GetReasonText: string;
begin
  Result := FReasonText;
end;

{ TDownloadResultDataNotExistsByStatusCode }

constructor TDownloadResultDataNotExistsByStatusCode.Create(AUrl,
  ARequestHead: string; AStatusCode: DWORD);
begin
  inherited Create(AUrl, ARequestHead, Format('������� �����������. ������ %d', [AStatusCode]));
end;

{ TDownloadResultDataNotExistsZeroSize }

constructor TDownloadResultDataNotExistsZeroSize.Create(AUrl,
  ARequestHead: string);
begin
  inherited Create(AUrl, ARequestHead, '������� ����� ������� ������');
end;

{ TDownloadResultLoadErrorByUnknownStatusCode }

constructor TDownloadResultLoadErrorByUnknownStatusCode.Create(AUrl,
  ARequestHead: string; AStatusCode: DWORD);
begin
  inherited Create(AUrl, ARequestHead, Format('����������� ������ %d', [AStatusCode]));
end;

end.
