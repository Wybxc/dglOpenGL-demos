unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, dglOpenGL;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormDblClick(Sender: TObject);
  private
    { Private declarations }
    X, Y, Z: Single;
    procedure ShowTrans; inline;
  public
    { Public declarations }
    DC: HDC;
    RC: HGLRC;
    procedure Display(Sender: TObject; var Done: Boolean);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Display(Sender: TObject; var Done: Boolean);
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // ����

  glLoadIdentity;
  glTranslatef(X, Y, Z);

  glBegin(GL_QUADS);
  begin
    glColor3f(1, 1, 0);
    glVertex3f(0, 0, 0);
    glColor3f(1, 1, 1);
    glVertex3f(1, 0, 0);
    glVertex3f(1, 1, 0);
    glVertex3f(0, 1, 0);
  end;
  glEnd;

  SwapBuffers(DC); // Ӧ�ø���

  Done := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle); // ��� DC
  if not InitOpenGL() then
    raise Exception.Create('��ʼ�� OpenGL ʧ��!'); // ��ʼ�� OpenGL
  RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0); // ��� RC
  ActivateRenderingContext(DC, RC); // �� DC, RC
  (*********)
  glShadeModel(GL_SMOOTH);  // ������ɫƽ��

  glClearColor(0, 0, 0, 0); // ���ñ�����ɫ

  glClearDepth(1.0);        // ������Ȼ���Ĭ��ֵ
  glDepthFunc(GL_LEQUAL);   // ������ȱȽ�ģʽ
  glEnable(GL_DEPTH_TEST);  // ����Ȳ���

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST); // ����ϵͳ��͸�ӽ��������������

  glEnable(GL_CULL_FACE);   // �򿪱����޳�
  (*********)
  Application.OnIdle := Display;
  (*********)
  X := 0;
  Y := 0;
  Z := -10;
  ShowTrans;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  X := 0;
  Y := 0;
  Z := -10;
  ShowTrans;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DeactivateRenderingContext; // ��� DC, RC
  wglDeleteContext(RC);       // �ͷ� RC
  ReleaseDC(Handle, DC);      // �ͷ� DC
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT:
      X := X - 0.1;
    VK_RIGHT:
      X := X + 0.1;
    VK_UP:
      Y := Y + 0.1;
    VK_DOWN:
      Y := Y - 0.1;
  end;
  ShowTrans;
end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Z := Z * 1.1;
  ;
  ShowTrans;
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Z := Z / 1.1;
  ShowTrans;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight); // �����Ӵ�
  (*********)
  glMatrixMode(GL_PROJECTION); // ����ͶӰ����
  glLoadIdentity; // ���õ�ǰ����Ϊ��λ��
  gluPerspective(45.0, ClientWidth / ClientHeight, NearClipping, FarClipping); // ���ó�����С
  (*********)
  glMatrixMode(GL_MODELVIEW); // ����ģ����ͼ����
  glLoadIdentity; // ���õ�ǰ����Ϊ��λ��
end;

procedure TForm1.ShowTrans;
begin
  Caption := Format('X:%f, Y:%f, Z:%f', [X, Y, Z]);
end;

end.

