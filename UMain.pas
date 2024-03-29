﻿Unit UMain;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.PNGImage, Vcl.ExtCtrls, Math,
    Vcl.StdCtrls;

Type
    TMainForm = Class(TForm)
    MainImage: TImage;
    Escape: TPanel;
    Hint: TLabel;
    Procedure FormCreate(Sender: TObject);
    Procedure FormKeyPress(Sender: TObject; var Key: Char);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    MainForm: TMainForm;

Implementation

Var
    CurrentPosX, CurrentPosY: Integer;
    KeyPosX, KeyPosY: Integer;
    PNG: TPNGImage;
    BMP: TBitmap;
    
    PNGKey: TPNGImage;
    BMPKey: TBitmap;

    KeyCollected, IsVictory: Boolean;

Type
    PTArray = Array of TPoint;

{$R *.dfm}

Procedure DrawBackground(MainImage: TImage);
Begin
    If KeyCollected then
        MainImage.Picture.LoadFromFile('..\..\Images\back_unlocked.bmp')
    Else
        MainImage.Picture.LoadFromFile('..\..\Images\back.bmp');
End;

Procedure DrawActorAgain(MainImage: TImage);
Begin
    MainImage.Canvas.Draw(CurrentPosX, CurrentPosY, BMP);
    If not KeyCollected then
        MainImage.Canvas.Draw(KeyPosX, KeyPosY, BMPKey);
End;

Procedure DeleteItem(Index: Byte; Var SpawnPoints: PTArray);
Var
    I: Integer;
Begin
    For I := Index to Length(SpawnPoints) - 1 do
    Begin
        SpawnPoints[I] := SpawnPoints[I + 1];
    End;
    SetLength(SpawnPoints, Length(SpawnPoints) - 1);
End;

Function FillSpawnPoints() : PTArray;
Var
    SpawnPoints: PTArray;
Begin
    SetLength(SpawnPoints, 4);
    SpawnPoints[0].X := 46;
    SpawnPoints[0].Y := 55;

    SpawnPoints[1].X := 46;
    SpawnPoints[1].Y := 335;

    SpawnPoints[2].X := 422;
    SpawnPoints[2].Y := 445;

    SpawnPoints[3].X := 420;
    SpawnPoints[3].Y := 55;

    Result := SpawnPoints;    
End;

Function GetRoomName(Id: Integer) : String;
Begin
    If ID = 0 then
        Result := 'зеленой'
    Else If ID = 1 then
        Result := 'красной'
    Else If ID = 2 then
        Result := 'синей'
    Else If ID = 3 then
        Result := 'желтой'
End;

Procedure TMainForm.FormCreate(Sender: TObject);
Var
    SpawnPoints: PTArray;
    SpanwPointID: Byte;
    RoomName: String;
Begin
    IsVictory := False;
    SpanwPointID := RandomRange(0, 4);
    KeyCollected := False;

    SpawnPoints := FillSpawnPoints;
    RoomName := GetRoomName(SpanwPointID);
    CurrentPosX := SpawnPoints[SpanwPointID].X;
    CurrentPosY := SpawnPoints[SpanwPointID].Y;
    
    BMP := TBitmap.Create;
    Try
        PNG := TPngImage.Create;
    Finally
        PNG.LoadFromFile('..\..\Images\actor1.png');
        BMP.Assign(PNG);
        MainImage.Canvas.Draw(CurrentPosX, CurrentPosY, BMP);
    End;

    DeleteItem(SpanwPointID, SpawnPoints);
    SpanwPointID := RandomRange(0, 3);
    KeyPosX := SpawnPoints[SpanwPointID].X;
    KeyPosY := SpawnPoints[SpanwPointID].Y;

    BMPKey := TBitmap.Create;
    Try
        PNGKey := TPngImage.Create;
    Finally
        PNGKey.LoadFromFile('..\..\Images\key.png');
        BMPKey.Assign(PNGKey);
        MainImage.Canvas.Draw(KeyPosX, KeyPosY, BMPKey);
    End; 

    ShowMessage('Вы попали на корабль. Вы находитесь в ' + RoomName + ' комнате. Пройдитесь по остальным комнатам чтобы найти ключ, и сбежать!');   
End;

Function CheckLeft(MainImage: TIMage) : Boolean;
Begin
    If (MainImage.Canvas.Pixels[CurrentPosX - 1, CurrentPosY + 16] = $00969696) then
        Result := False
    Else
        Result := True;
End;

Function CheckBottom(MainImage: TIMage) : Boolean;
Begin
    If (MainImage.Canvas.Pixels[CurrentPosX + 16, CurrentPosY + 35] = $00969696) then
        Result := False
    Else
        Result := True;
End;

Function CheckUp(MainImage: TIMage) : Boolean;
Begin
    If (MainImage.Canvas.Pixels[CurrentPosX + 16, CurrentPosY - 3] = $00969696) then
        Result := False
    Else
        Result := True;
End;

Function CheckRight(MainImage: TIMage) : Boolean;
Begin
    If (MainImage.Canvas.Pixels[CurrentPosX + 35, CurrentPosY + 16] = $00969696) then
        Result := False
    Else
        Result := True;
End;


Procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
Var
    KeyRect : TRect;
Begin
    If not IsVictory then
    Begin
        If (Key = 's') then
        Begin
            If (CheckBottom(MainImage)) then
            Begin
                CurrentPosY := CurrentPosY + 3;
                DrawBackground(MainImage);
                DrawActorAgain(MainImage);
            End;
        End;
        If (Key = 'w') then
        Begin
            If (CheckUp(MainImage)) then
            Begin
                CurrentPosY := CurrentPosY - 3;
                DrawBackground(MainImage);
                DrawActorAgain(MainImage);
            End;
        End;
        If (Key = 'a') then
        Begin
            If (CheckLeft(MainImage)) then
            Begin
                CurrentPosX := CurrentPosX - 3;
                DrawBackground(MainImage);
                DrawActorAgain(MainImage);
            End;
        End;
        If (Key = 'd') then
        Begin
            If (CheckRight(MainImage)) then
            Begin
                CurrentPosX := CurrentPosX + 3;
                DrawBackground(MainImage);
                DrawActorAgain(MainImage);
            End;
        End;

        If not KeyCollected then
        Begin
            KeyRect := Rect(KeyPosX, KeyPosY, KeyPosX + 32, KeyPosY + 32); 
            If PtInRect(KeyRect, Point(CurrentPosX + 16, CurrentPosY + 16)) then
            Begin
                KeyCollected := True;
                DrawBackground(MainImage);
                DrawActorAgain(MainImage);
                ShowMessage('Вы нашли ключ! Теперь вы можете сбежать с корабля!');
                Hint.Caption := 'У вас есть ключ. Идите к выходу.'
            End;
        End;

        If KeyCollected then
        Begin
            KeyRect := Rect(Escape.Left, Escape.Top, Escape.Left + Escape.Width, Escape.Top + Escape.Height);
            If PtInRect(KeyRect, Point(CurrentPosX + 16, CurrentPosY + 16)) then
            Begin     
                ShowMessage('Вы успешно сбежали с корабля!'); 
                Hint.Caption := 'Вы сбежали с корабля. Перезайдите в игру, чтобы начать заново.'; 
                IsVictory := True;
            End;
        End;
    End;
End;

End.
