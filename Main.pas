unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, dglOpenGL;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
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
  SwapBuffers(DC); // Ӧ�ø���
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle); // ��� DC
  if not InitOpenGL() then
    raise Exception.Create('��ʼ�� OpenGL ʧ��!'); // ��ʼ�� OpenGL
  RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0); // ��� RC
  ActivateRenderingContext(DC, RC); // �� DC, RC
  (*********)
  glClearColor(0, 0, 0, 0); // ���ñ�����ɫ
  glEnable(GL_DEPTH_TEST);  // ����Ȳ���
  glEnable(GL_CULL_FACE);   // �򿪱����޳�
  (*********)
  Application.OnIdle := Display;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DeactivateRenderingContext; // ��� DC, RC
  wglDeleteContext(RC);       // �ͷ� RC
  ReleaseDC(Handle, DC);      // �ͷ� DC
end;

procedure TForm1.FormResize(Sender: TObject);
const
  NearClipping = 1;
  FarClipping = 1000;
begin
  glViewport(0, 0, ClientWidth, ClientHeight); // �����Ӵ�
  glMatrixMode(GL_PROJECTION); // ����ͶӰ����
  glLoadIdentity; // ���õ�ǰ����Ϊ��λ��
  gluPerspective(45.0, ClientWidth / ClientHeight, NearClipping, FarClipping); // ���ó�����С
  glMatrixMode(GL_MODELVIEW); // ����ģ����ͼ����
  glLoadIdentity; // ���õ�ǰ����Ϊ��λ��
end;

end.

