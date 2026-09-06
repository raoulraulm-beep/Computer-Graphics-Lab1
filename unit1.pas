unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtDlgs,
  ExtCtrls,
  LCLIntf, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    t: TImage;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  // Si l'utilisateur sélectionne un fichier et clique sur OK
  if OpenPictureDialog1.Execute then
  begin
    // On charge l'image sélectionnée dans le composant TImage nommé 't'
    t.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Bmp: TBitmap;
begin
  // Sécurité : On vérifie qu'une image a bien été chargée
  if (t.Picture.Graphic = nil) or (t.Picture.Graphic.Empty) then
  begin
    ShowMessage('Veuillez d''abord ouvrir une image !');
    Exit;
  end;

  // 1. Création d'un Bitmap temporaire en mémoire
  Bmp := TBitmap.Create;
  try
    // 2. Configuration de la taille et du format d'après votre photo originale
    Bmp.PixelFormat := pf24bit;
    Bmp.Width := t.Picture.Graphic.Width;
    Bmp.Height := t.Picture.Graphic.Height;

    // 3. On dessine la photo d'origine sur ce Bitmap tout neuf
    Bmp.Canvas.Draw(0, 0, t.Picture.Graphic);

    // 4. Application des 3 points de la variante 10 sur le Bitmap
    // Point 1 : Coin supérieur gauche
    Bmp.Canvas.Pixels[0, 0] := RGB(64, 64, 255);

    // Point 2 : Coin supérieur droit
    Bmp.Canvas.Pixels[Bmp.Width - 1, 0] := RGB(255, 255, 64);

    // Point 3 : Coin inférieur gauche
    Bmp.Canvas.Pixels[0, Bmp.Height - 1] := RGB(255, 64, 255);

    // 5. On renvoie le Bitmap modifié dans le composant d'affichage
    t.Picture.Assign(Bmp);

  finally
    // 6. Libération de la mémoire
    Bmp.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // Si l'utilisateur choisit un emplacement, un nom de fichier et clique sur Enregistrer
  if SavePictureDialog1.Execute then
  begin
    // On sauvegarde le contenu du TImage vers le fichier spécifié
    t.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  TxtFile: TextFile;
  px, py: Integer;
  Gray: Byte;
  BinaryValue: Char;
  CurrentColor: TColor;
begin
  // Safety check: Verify that an image is available
  if (t.Picture.Graphic = nil) or (t.Picture.Graphic.Empty) then
  begin
    ShowMessage('Please open and process an image first!');
    Exit;
  end;

  // Set the save dialog filter specifically for PBM files
  SavePictureDialog1.Filter := 'Portable Bitmap (*.pbm)|*.pbm';

  if SavePictureDialog1.Execute then
  begin
    // Link the file variable to the chosen filename and open it for writing
    AssignFile(TxtFile, SavePictureDialog1.FileName);
    Rewrite(TxtFile);

    // Write the PBM ASCII header (P1 format)
    Writeln(TxtFile, 'P1');
    Writeln(TxtFile, IntToStr(t.Picture.Width) + ' ' + IntToStr(t.Picture.Height));

    // Process each pixel row by row
    with t.Picture.Bitmap do
    begin
      for py := 0 to Height - 1 do
      begin
        for px := 0 to Width - 1 do
        begin
          // Get the color data of the current pixel
          CurrentColor := Canvas.Pixels[px, py];

          // Calculate perceived brightness (Grayscale) formula
          Gray := Round(0.299 * GetRValue(CurrentColor) +
                        0.587 * GetGValue(CurrentColor) +
                        0.114 * GetBValue(CurrentColor));

          // Thresholding at 127: In standard ASCII PBM, '0' is white and '1' is black
          if Gray > 127 then
            BinaryValue := '0'
          else
            BinaryValue := '1';

          // Write the binary digit followed by a space
          Write(TxtFile, BinaryValue + ' ');
        end;
        Writeln(TxtFile); // Move to a new line at the end of each row
      end;
    end;

    // Close the file stream cleanly
    CloseFile(TxtFile);
    ShowMessage('PBM text file exported successfully!');
  end;
end;

end.
