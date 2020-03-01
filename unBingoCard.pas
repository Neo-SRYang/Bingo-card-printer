unit unBingoCard;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ExtCtrls, Printers, Dialogs, PrintersDlgs;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    tbNumberBase: TTrackBar;
    tbCardSize: TTrackBar;
    Label3: TLabel;
    eTitle: TEdit;
    lbNumberBase: TLabel;
    lbSize: TLabel;
    btnPreview: TButton;
    btnPrint: TButton;
    Label4: TLabel;
    tbCardCount: TTrackBar;
    lbCardCount: TLabel;
    Label5: TLabel;
    PaintBox1: TPaintBox;
    Label6: TLabel;
    cbFont: TComboBox;
    btnPrinterSetup: TButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    btnPrint2: TButton;
    Label7: TLabel;
    lbPrinterName: TLabel;
    Bevel1: TBevel;
    btnAbout: TButton;
    procedure tbNumberBaseChange(Sender: TObject);
    procedure tbCardSizeChange(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure tbCardCountChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPrinterSetupClick(Sender: TObject);
    procedure btnPrint2Click(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
  private
    { Private declarations }
    Cards: array of integer;
    procedure PaintCard(Canvas: TCanvas; dpi: integer; XCount, YCount: integer;
      XOffset, YOffset: integer; Title: String; Data: Array of integer);
    procedure InitCardDeck;
    procedure ShuffleCard;
    function ScreenToPrinter(dpi, n: integer): integer;
    procedure CheckNumbers;
    procedure ClearPreview;
    function PaintStick(Canvas: TCanvas; dpi: integer; fromN, maxN: integer): integer;
    procedure ShowCurrPrinter;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses unAbout;

procedure TForm1.btnAboutClick(Sender: TObject);
begin
  if Application.FindComponent('fmAbout') = nil then
    Application.CreateForm(TfmAbout, fmAbout);
  fmAbout.ShowModal;
end;

procedure TForm1.btnPreviewClick(Sender: TObject);
begin
  InitCardDeck;
  ShuffleCard;
  ClearPreview;
  PaintCard(PaintBox1.Canvas, Screen.PixelsPerInch,
    tbCardSize.Position, tbCardSize.Position, 0, 0, eTitle.Text, Cards);
end;

procedure TForm1.btnPrint2Click(Sender: TObject);
var
  i, n, c, dpi: Integer;
  XOffset, YOffset: integer;
begin
  dpi := Printer.XDPI;
  Printer.Title := '籤紙';
  Printer.BeginDoc;
  n := 1;

  while n < tbNumberBase.Position do
  begin
    n := PaintStick(Printer.Canvas, dpi, n, tbNumberBase.Position);

    if (n < tbNumberBase.Position) then
      Printer.NewPage;
  end;

  Printer.EndDoc;
end;

procedure TForm1.btnPrintClick(Sender: TObject);
var
  i, n, dpi: Integer;
  XOffset, YOffset: integer;
  cardCount: integer;
begin
  InitCardDeck;

  cardCount := tbCardCount.Position * 6;
  n := 0;
  dpi := Printer.XDPI;
  Printer.Title := '賓果卡';
  Printer.BeginDoc;
  for i := 0 to cardCount - 1 do
  begin
    ShuffleCard;

    XOffset := 35 + 380 * (n mod 2);
    YOffset := 30 + 360 * (n div 2);

    PaintCard(Printer.Canvas, dpi, tbCardSize.Position, tbCardSize.Position,
          XOffset, YOffset, eTitle.Text, Cards);
    Inc(n);

    if (n = 6) and (i < cardCount - 1) then
    begin
      Printer.NewPage;
      n := 0;
    end;
  end;
  Printer.EndDoc;
end;

procedure TForm1.CheckNumbers;
begin
  if tbNumberBase.Position < tbCardSize.Position * tbCardSize.Position then
  begin
    btnPreview.Enabled := False;
    btnPrint.Enabled := False;
  end
  else
  begin
    btnPreview.Enabled := True;
    btnPrint.Enabled := True;
  end;
end;

procedure TForm1.ClearPreview;
begin
  PaintBox1.Canvas.Brush.Color := clWhite;
  PaintBox1.Canvas.FillRect(PaintBox1.Canvas.ClipRect);
end;

// 初始牌堆
procedure TForm1.InitCardDeck;
var i: integer;
begin
  SetLength(Cards, tbNumberBase.Position);
  for i := 1 to tbNumberBase.Position do
    Cards[i - 1] := i;
end;

// 轉換座標
function TForm1.ScreenToPrinter(dpi, n: integer): integer;
begin
  Result := Trunc(n * dpi / Screen.PixelsPerInch);
end;

// 畫賓果卡
procedure TForm1.PaintCard(Canvas: TCanvas; dpi: integer; XCount, YCount: integer;
  XOffset, YOffset: integer; Title: String; Data: Array of integer);
var
  AWidth,
  AHeight,
  ATitleHeight,
  ABorderWidth,
  ATextWidth,
  ATextHeight,
  XInterval,
  YInterval : integer;
  i, j: Integer;
  s: string;
  ABorderRect: TRect;
begin
  AWidth := ScreenToPrinter(dpi, 342);
  AHeight := ScreenToPrinter(dpi, 342);
  ATitleHeight := ScreenToPrinter(dpi, 38);
  ABorderWidth := ScreenToPrinter(dpi, 14);
  XInterval := (AWidth - ABorderWidth * 2) div XCount;
  YInterval := (AHeight - ATitleHeight - ABorderWidth) div YCount;
  XOffset := ScreenToPrinter(dpi, XOffset);
  YOffset := ScreenToPrinter(dpi, YOffset);

  // 畫抬頭文字
  Canvas.Font.Name := cbFont.Text;
  Canvas.Font.Size := 22;
  Canvas.Font.Style := [fsBold];
  Canvas.Pen.Width := ScreenToPrinter(dpi, 3);
  ATextWidth := Canvas.TextWidth(Title);
  Canvas.TextOut((AWidth - ATextWidth) div 2 + XOffset, YOffset, Title);

  // 畫格子中間的字
  case XCount of
    3: Canvas.Font.Size := 46;
    4: Canvas.Font.Size := 40;
    5: Canvas.Font.Size := 30;
    6: Canvas.Font.Size := 24;
    7: Canvas.Font.Size := 20;
    8: Canvas.Font.Size := 16;
    9: Canvas.Font.Size := 14;
    10: Canvas.Font.Size := 11;
  end;
  for i := 1 to XCount do
  begin
    for j := 1 to YCount do
    begin
      s := IntToStr(Data[(i - 1) * XCount + (j - 1)]);
      ATextWidth := Canvas.TextWidth(s);
      ATextHeight := Canvas.TextHeight(s);
      Canvas.TextOut(ABorderWidth + XInterval * (i - 1) + (XInterval - ATextWidth) div 2 + XOffset,
                     ATitleHeight + YInterval * (j - 1) + (YInterval - ATextHeight) div 2 + YOffset,
                     s);
    end;
  end;

  // 畫邊框
  ABorderRect.Left := ABorderWidth + XOffset;
  ABorderRect.Top := ATitleHeight + YOffset;
  ABorderRect.Right := AWidth - ABorderWidth + XOffset;
  ABorderRect.Bottom := AHeight - ABorderWidth + YOffset;

  Canvas.MoveTo(ABorderRect.Left, ABorderRect.Top);
  Canvas.LineTo(ABorderRect.Right, ABorderRect.Top);
  Canvas.LineTo(ABorderRect.Right, ABorderRect.Bottom);
  Canvas.LineTo(ABorderRect.Left, ABorderRect.Bottom);
  Canvas.LineTo(ABorderRect.Left, ABorderRect.Top);
  //  .Rectangle(ABorderWidth + XOffset, ATitleHeight + YOffset,
  //                 AWidth - ABorderWidth + XOffset, AHeight - ABorderWidth + YOffset);

  // 畫垂直分隔線
  for i := 1 to XCount - 1 do
  begin
    Canvas.MoveTo(ABorderWidth + XInterval * i + XOffset, ATitleHeight + YOffset);
    Canvas.LineTo(ABorderWidth + XInterval * i + XOffset, AHeight - ABorderWidth + YOffset);
  end;

  // 畫水平分隔線
  for i := 1 to YCount - 1 do
  begin
    Canvas.MoveTo(ABorderWidth + XOffset, ATitleHeight + YInterval * i + YOffset);
    Canvas.LineTo(AWidth - ABorderWidth + XOffset, ATitleHeight + YInterval * i + YOffset);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  cbFont.Items.Assign(Printer.Fonts);
  cbFont.ItemIndex := cbFont.Items.IndexOf('Arial');
  ShowCurrPrinter;
end;

// 畫籤紙
function TForm1.PaintStick(Canvas: TCanvas; dpi: integer; fromN, maxN: integer): integer;
var
  i: Integer;
  j: Integer;
  s: string;
  n: Integer;
  ATextWidth: Integer;
  ATextHeight: Integer;
  XBorder: Integer;
  YBorder: Integer;
  XInterval: Integer;
  YInterval: Integer;
  ABorderRect: TRect;
  XCount: Integer;
  YCount: Integer;
begin
  n := fromN;

  Canvas.Font.Name := 'Arial';
  Canvas.Font.Size := 60;
  Canvas.Font.Style := [fsBold, fsUnderline];

  XBorder := ScreenToPrinter(dpi, 56);
  YBorder := ScreenToPrinter(dpi, 56);
  XInterval := ScreenToPrinter(dpi, 170);
  YInterval := ScreenToPrinter(dpi, 170);
  XCount := 4;
  YCount := 6;

  // 畫邊框
  ABorderRect.Left := XBorder;
  ABorderRect.Top := YBorder;
  ABorderRect.Right := XInterval * XCount + XBorder;
  ABorderRect.Bottom := YInterval * YCount + YBorder;

  Canvas.MoveTo(ABorderRect.Left, ABorderRect.Top);
  Canvas.LineTo(ABorderRect.Right, ABorderRect.Top);
  Canvas.LineTo(ABorderRect.Right, ABorderRect.Bottom);
  Canvas.LineTo(ABorderRect.Left, ABorderRect.Bottom);
  Canvas.LineTo(ABorderRect.Left, ABorderRect.Top);

  // 畫垂直分隔線
  for i := 1 to XCount - 1 do
  begin
    Canvas.MoveTo(XBorder + XInterval * i, ABorderRect.Top);
    Canvas.LineTo(XBorder + XInterval * i, ABorderRect.Bottom);
  end;

  // 畫水平分隔線
  for i := 1 to YCount - 1 do
  begin
    Canvas.MoveTo(ABorderRect.Left, YBorder + YInterval * i);
    Canvas.LineTo(ABorderRect.Right, YBorder + YInterval * i);
  end;

  // 畫格子中間的字
  for i := 1 to YCount do
  begin
    for j := 1 to XCount do
    begin
      s := IntToStr(n);
      ATextWidth := Canvas.TextWidth(s);
      ATextHeight := Canvas.TextHeight(s);
      Canvas.TextOut(XBorder + XInterval * (j - 1) + (XInterval - ATextWidth) div 2,
                     YBorder + YInterval * (i - 1) + (YInterval - ATextHeight) div 2,
                     s);
      Inc(n);
      if n > maxN then
      begin
        Result := n;
        Exit;
      end;
    end;
  end;
  Result := n;
end;

procedure TForm1.ShowCurrPrinter;
begin
  if (Printer.Printers.Count = 0) then
    lbPrinterName.Caption := '目前沒有安裝印表機'
  else if (Printer.PrinterIndex = -1) then
    lbPrinterName.Caption := '目前沒有指定預設印表機'
  else
    lbPrinterName.Caption := Printer.Printers[Printer.PrinterIndex];
end;

// 洗牌
procedure TForm1.ShuffleCard;
var
  i, n, x: Integer;
begin
  Randomize;
  for i := 1 to tbNumberBase.Position do
  begin
    x := Random(tbNumberBase.Position);
    n := Cards[i - 1];
    Cards[i - 1] := Cards[x];
    Cards[x] := n;
  end;
end;

procedure TForm1.tbNumberBaseChange(Sender: TObject);
begin
  lbNumberBase.Caption := Format('%0:d', [tbNumberBase.Position]);
  CheckNumbers;
end;

procedure TForm1.tbCardCountChange(Sender: TObject);
begin
  lbCardCount.Caption := Format('%0:d (%1:d張)', [tbCardCount.Position, tbCardCount.Position * 6]);
end;

procedure TForm1.tbCardSizeChange(Sender: TObject);
begin
  lbSize.Caption := Format('%0:d x %0:d', [tbCardSize.Position]);
  CheckNumbers;
end;

procedure TForm1.btnPrinterSetupClick(Sender: TObject);
begin
  if PrinterSetupDialog1.Execute then
  begin
    ShowCurrPrinter;
  end;
end;

end.
