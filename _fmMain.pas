unit _fmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.ExtCtrls;

type
  TfmMain = class(TForm)
    Config: TValueListEditor;
    procedure ConfigValidate(Sender: TObject; ACol, ARow: Integer;
      const KeyName, KeyValue: string);
    procedure ConfigSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
  private
    { Private declarations }
    FFileName: String;
    procedure Initialize;
    procedure GetValues;
    procedure WritePosition;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
    procedure AfterConstruction; override;
  end;

var
  fmMain: TfmMain;

implementation

uses
  System.IniFiles, System.IOUtils;

var
  ConfigName: String;

{$R *.dfm}

{ TfmMain }

procedure TempObjectProc(AInstance: TObject; AProc: TProc<TObject>);
begin
  try
    AProc(AInstance);
  finally
    AInstance.Free;
  end;
end;

procedure IniProc(const AFileName: String; AProc: TProc<TIniFile>);
begin
  if AFileName.IsEmpty = False then begin
    TempObjectProc(TIniFile.Create(AFileName), TProc<TObject>(AProc));
  end;
end;

procedure GetKeyList(Ini: TIniFile; AList: TStrings);
begin
  if Assigned(Ini) then begin
    TempObjectProc(TStringList.Create, TProc<TObject>(procedure (SectionList: TStringList)
    var
      I: Integer;
    begin
      SectionList.Duplicates := dupIgnore;
      SectionList.Sorted := True;

      Ini.ReadSections(SectionList);

      SectionList.Sorted := False;
      for I := Pred(SectionList.Count) downto 0 do begin
        if Ini.ReadBool(SectionList.Strings[I], 'Define', False) then begin
          SectionList.Delete(I);
        end else begin
          SectionList.Strings[I] := SectionList.Strings[I] + '=';
        end;
      end;
      AList.Assign(SectionList);
    end));
  end else begin
    IniProc(ConfigName, procedure (Ini: TIniFile)
    begin
      GetKeyList(Ini, AList);
    end);
  end;
end;

procedure GetValueList(Ini: TIniFile; AList: TStrings; const KeyName: string);
var
  Section: string;
  Value: string;
begin
  if Assigned(Ini) then begin
    Value := KeyName;
    repeat
      Section := Value;
      Value := Ini.ReadString(Value, 'Type', '');
    until Value.IsEmpty;
    AList.CommaText := Ini.ReadString(Section, 'ValueList', '');
  end else begin
    IniProc(ConfigName, procedure (Ini: TIniFile)
    begin
      GetValueList(Ini, AList, KeyName);
    end);
  end;
end;

procedure TfmMain.AfterConstruction;
begin
  inherited;
  Initialize;
  if FFileName.IsEmpty = False then begin
    Caption := Format('%s - %s', [Application.Title, ExtractFileName(FFileName)]);
    GetValues;
  end else begin
    Application.MessageBox('FileName is not defined.', PChar(Application.Title), MB_ICONERROR or MB_OK);
    Application.ShowMainForm := False;
    Application.Terminate;
  end;
end;

procedure TfmMain.ConfigSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var
  iIndex: Integer;
begin
  iIndex := ARow - (Config.RowCount - Config.Strings.Count);
  if not iIndex in [0..Pred(Config.Strings.Count)] then begin
    Exit;
  end;

  if Value.IsEmpty and not TFile.Exists(FFileName) then begin
    Exit;
  end;

  TempObjectProc(TStringList.Create, TProc<TObject>(procedure (Key: TStringList)
  begin
    Key.Delimiter := '/';
    Key.DelimitedText := Config.Strings.Names[iIndex];
    IniProc(FFileName, procedure (Ini: TIniFile)
    begin
      Ini.WriteString(Key.Strings[0], Key.Strings[1], Value);
    end);
  end));
end;

procedure TfmMain.ConfigValidate(Sender: TObject; ACol, ARow: Integer;
  const KeyName, KeyValue: string);
var
  ItemProps: TItemProp;
  I: Integer;
begin
  ItemProps := Config.ItemProps[KeyName];
  if ItemProps.HasPickList then begin
    for I := 0 to Pred(ItemProps.PickList.Count) do begin
      if Pos(KeyValue, ItemProps.PickList.Strings[I]) = 1 then begin
        Config.Values[Keyname] := ItemProps.PickList.Strings[I];
      end;
    end;
  end;
end;

procedure TfmMain.Initialize;
var
  Value: string;
  Pos: array[0..Pred(4)] of Integer;
begin
  if ParamCount > 0 then begin
    if TFile.Exists(ParamStr(1)) then begin
      ConfigName := ParamStr(1);
    end;
  end;
  IniProc(ConfigName, procedure (Ini: TIniFile)
  var
    I: Integer;
  begin
    // Key
    GetKeyList(Ini, Config.Strings);

    // PickList
    for I := 0 to Pred(Config.Strings.Count) do begin
      GetValueList(Ini, Config.ItemProps[I].PickList, Config.Keys[I + 1]);
      if Config.ItemProps[I].PickList.Count > 0 then begin
        Config.ItemProps[I].EditStyle := esPickList;
      end;

      Value := Ini.ReadString(Config.Keys[I + 1], 'Desc', '');
      if not Value.IsEmpty then begin
        Config.ItemProps[I].KeyDesc := Value;
      end;
    end;

    // Config
    FFileName := Ini.ReadString('Config', 'FileName', '');
    if FFileName.IsEmpty = False then begin
      FFileName := ExtractFilePath(ParamStr(0)) + FFileName;
    end;
    TempObjectProc(TStringList.Create, TProc<TObject>(procedure (Reader: TStringList)
    begin
      Reader.CommaText := Ini.ReadString('Config', 'Position', '');
      if (Reader.Count >= 4)
        and TryStrToInt(Reader.Strings[0], Pos[0])
        and TryStrToInt(Reader.Strings[1], Pos[1])
        and TryStrToInt(Reader.Strings[2], Pos[2])
        and TryStrToInt(Reader.Strings[3], Pos[3]) then begin
        Position := poDesigned;
        SetBounds(Pos[0], Pos[1], Pos[2], Pos[3]);
      end;
    end));
  end);
end;

procedure TfmMain.WritePosition;
begin
  IniProc(ConfigName, procedure (Ini: TIniFile)
  begin
    TempObjectProc(TStringList.Create, TProc<TObject>(procedure (Reader: TStringList)
    begin
      Reader.Add(IntToStr(Left));
      Reader.Add(IntToStr(Top));
      Reader.Add(IntToStr(Width));
      Reader.Add(IntToStr(Height));
      Ini.WriteString('Config', 'Position', Reader.CommaText);
    end));
  end);
end;

procedure TfmMain.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg = WM_WINDOWPOSCHANGED then begin
    if not (fsCreating in FormState) then begin
      WritePosition;
    end;
  end;
end;

procedure TfmMain.GetValues;
begin
  TempObjectProc(TStringList.Create, TProc<TObject>(procedure (Key: TStringList)
  begin
    Key.Delimiter := '/';
    IniProc(FFileName, procedure (Ini: TIniFile)
    var
      I: Integer;
      Value: String;
    begin
      for I := 0 to Pred(Config.Strings.Count) do begin
        Key.DelimitedText := Config.Strings.Names[I];
        if Key.Count >= 2 then begin
          Value := Ini.ReadString(Key.Strings[0], Key.Strings[1], '');
          if Value.IsEmpty = False then begin
            Config.Strings.ValueFromIndex[I] := Value;
          end;
        end;
      end;
    end);
  end));
end;

Initialization
  ConfigName := ChangeFileExt(ParamStr(0), '.ini');

end.

