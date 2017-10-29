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
    procedure glColorVertex(Color, Vertex: PGLfloat); inline;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Display(Sender: TObject; var Done: Boolean);
const
  Red: array[1..3] of Single = (1, 0, 0);
  Green: array[1..3] of Single = (0, 1, 0);
  Blue: array[1..3] of Single = (0, 0, 1);
  White: array[1..3] of Single = (1, 1, 1);
  // ������ɫ����
  A: array[1..3] of Single = (0, 0, 0);
  B: array[1..3] of Single = (2, 0, 0);
  C: array[1..3] of Single = (1, 0, 1.732); // (1, 0, Sqrt(3))
  P: array[1..3] of Single = (1, 1.732, 0.57735); // (1, Sqrt(3), 1 / Sqrt(3))
  // ���嶥�㳣��
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // ����

  // ��ͼ�Ĳ������������

  glLoadIdentity;          // ��ԭ����ϵ
  glTranslatef(0, 0, -5); // ����ԭ������Ļ�ڲ��ƶ�5����λ����

  glBegin(GL_QUADS); // ���������ľ���
  begin              // ��������
    glColor3f(1, 1, 0); // OpenGL.Pen.Color := RGB(1, 1, 0);
    glVertex3f(0, 0, 0); // ��һ������(��ɫ), λ������ԭ��
    glColor3f(1, 1, 1); // OpenGL.Pen.Color := RGB(1, 1, 1);
    glVertex3f(1, 0, 0); // �ڶ��������ĸ�����(��ɫ)
    glVertex3f(1, 1, 0);
    glVertex3f(0, 1, 0);
  end;
  glEnd;             // ������ͼ

  glTranslatef(-3, 0, 0); // ����ԭ�������ƶ�3����λ����

  glBegin(GL_TRIANGLES); // ����������������
  begin
    glColor3fv(@Red); // ʹ��ָ��, OpenGL.Pen.Color := ToColor(@Red);
    glVertex3fv(@A);
    glColorVertex(@Green, @B); // ����򵥷��� glColorVertex
    glColorVertex(@Blue, @C);
    // �������
    glColorVertex(@Red, @A);
    glColorVertex(@Green, @B);
    glColorVertex(@White, @P);
    // ������� 1/3
    glColorVertex(@Green, @B);
    glColorVertex(@Blue, @C);
    glColorVertex(@White, @P);
    // ������� 2/3
    glColorVertex(@Blue, @C);
    glColorVertex(@Red, @A);
    glColorVertex(@White, @P);
    // �������
  end;               // ��������
  glEnd;             // ������ͼ

  SwapBuffers(DC); // Ӧ�ø���

  Done := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle); // ��� DC
  if not InitOpenGL then
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
  (*********)
  glMatrixMode(GL_PROJECTION); // ����ͶӰ����
  glLoadIdentity; // ���õ�ǰ����Ϊ��λ��
  gluPerspective(45.0, ClientWidth / ClientHeight, NearClipping, FarClipping); // ���ó�����С
  (*********)
  glMatrixMode(GL_MODELVIEW); // ����ģ����ͼ����
  glLoadIdentity; // ���õ�ǰ����Ϊ��λ��
end;

procedure TForm1.glColorVertex(Color, Vertex: PGLfloat);
begin
  glColor3fv(Color);
  glVertex3fv(Vertex);
end;

end.

