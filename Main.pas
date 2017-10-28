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
  private
    { Private declarations }
    X, Y, Z: Integer;
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
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // 清屏

  glLoadIdentity;
  glTranslatef(X / 10, Y / 10, Z / 10);

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

  SwapBuffers(DC); // 应用更改

  Done := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle); // 获得 DC
  if not InitOpenGL() then
    raise Exception.Create('初始化 OpenGL 失败!'); // 初始化 OpenGL
  RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0); // 获得 RC
  ActivateRenderingContext(DC, RC); // 绑定 DC, RC
  (*********)
  glShadeModel(GL_SMOOTH);
  glClearColor(0, 0, 0, 0); // 设置背景颜色

  glClearDepth(1.0);        // 设置深度缓存默认值
  glDepthFunc(GL_LEQUAL);   // 设置深度比较模式

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST); // 告诉系统对透视进行最高质量修正

  glEnable(GL_DEPTH_TEST);  // 打开深度测试
  glEnable(GL_CULL_FACE);   // 打开背面剔除
  (*********)
  Application.OnIdle := Display;
  (*********)
  X := 0;
  Y := 0;
  Z := -100;
  Caption := Format('X:%f, Y:%f, Z:%f', [X / 10, Y / 10, Z / 10]);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DeactivateRenderingContext; // 解绑 DC, RC
  wglDeleteContext(RC);       // 释放 RC
  ReleaseDC(Handle, DC);      // 释放 DC
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT:
      Dec(X);
    VK_RIGHT:
      Inc(X);
    VK_UP:
      Inc(Y);
    VK_DOWN:
      Dec(Y);
  end;
  Caption := Format('X:%f, Y:%f, Z:%f', [X / 10, Y / 10, Z / 10]);
end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Dec(Z);
  Caption := Format('X:%f, Y:%f, Z:%f', [X / 10, Y / 10, Z / 10]);
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Inc(Z);
  Caption := Format('X:%f, Y:%f, Z:%f', [X / 10, Y / 10, Z / 10]);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight); // 设置视窗

  glMatrixMode(GL_PROJECTION); // 更改投影矩阵
  glLoadIdentity; // 设置当前矩阵为单位阵
  gluPerspective(45.0, ClientWidth / ClientHeight, 1, 1000); // 设置场景大小

  glMatrixMode(GL_MODELVIEW); // 更改模型视图矩阵
  glLoadIdentity; // 设置当前矩阵为单位阵
end;

end.

