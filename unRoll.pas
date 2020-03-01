unit unRoll;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, Buttons, ExtCtrls, ComCtrls, fgl;

type

  { TForm3 }

  TForm3 = class(TForm)
    btnNextNumber: TSpeedButton;
    Panel1: TPanel;
    Label1: TLabel;
    Panel4: TPanel;
    txtNumberRange: TSpinEdit;
    btnShuffle: TSpeedButton;
    Panel2: TPanel;
    Label3: TLabel;
    lvHistory: TListView;
    Panel3: TPanel;
    lbNextCard: TLabel;
    procedure btnShuffleClick(Sender: TObject);
    procedure btnNextNumberClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    CardDeck: TFPGList<integer>;
    CardNo: integer;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

// 搖號
procedure TForm3.btnNextNumberClick(Sender: TObject);
var
  i, r: Integer;
begin
  if CardNo >= txtNumberRange.Value then
    Exit;

  for i := 0 to 30 do
  begin
    r := Random(txtNumberRange.Value);
    lbNextCard.Caption := IntToStr(r);
    lbNextCard.Refresh;
    Sleep(2);
  end;

  // 隨機抽出下一張牌
  Randomize;
  r := Random(txtNumberRange.Value - CardNo);

  lbNextCard.Caption := IntToStr(CardDeck[r]);

  // 從牌堆中拿走發過的牌
  CardDeck.Remove(CardDeck[r]);

  with lvHistory.Items.Insert(0) do
  begin
    Caption := IntToStr(txtNumberRange.Value - CardNo);
    SubItems.Add(IntToStr(CardNo + 1));
    SubItems.Add(lbNextCard.Caption);
  end;
  lvHistory.ItemIndex := 0;
  lvHistory.Repaint;

  CardNo := CardNo + 1;
  if CardNo >= txtNumberRange.Value then
  begin
    btnNextNumber.Caption := '結　　束';
    btnNextNumber.Enabled := False;
    Application.ProcessMessages;
  end;
end;

// 重新洗牌
procedure TForm3.btnShuffleClick(Sender: TObject);
var
  i, r, n: Integer;
begin
  lvHistory.Items.Clear;

  // 初始化牌堆
  CardDeck.Clear;

  for i := 1 to txtNumberRange.Value do
  begin
    CardDeck.Add(i);
  end;

  // 洗牌(假的)
  for i := 1 to txtNumberRange.Value do
  begin
    r := Random(txtNumberRange.Value);

    lbNextCard.Caption := IntToStr(r);
    lbNextCard.Repaint;
    Sleep(3);
  end;

  CardNo := 0;
  lbNextCard.Caption := '?';
  btnNextNumber.Caption := '搖 (空白鍵) 號';
  btnNextNumber.Enabled := True;
end;

procedure TForm3.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  btnShuffle.Click;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  CardDeck := TFPGList<integer>.Create;
end;

procedure TForm3.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_SPACE then
  begin
    if btnNextNumber.Enabled then
    begin
      btnNextNumber.Click;
    end;
    Key := 0;
  end;
end;

procedure TForm3.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F12 then
  begin
    btnShuffle.Click;
    Key := 0;
  end;
end;

end.
