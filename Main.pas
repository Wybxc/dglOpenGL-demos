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
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // 清屏
  SwapBuffers(DC); // 应用更改
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle); // 获得 DC
  if not InitOpenGL() then
    raise Exception.Create('初始化 OpenGL 失败!'); // 初始化 OpenGL
  RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0); // 获得 RC
  ActivateRenderingContext(DC, RC); // 绑定 DC, RC
  (*********)
  glClearColor(0, 0, 0, 0); // 设置背景颜色
  glEnable(GL_DEPTH_TEST);  // 打开深度测试
  glEnable(GL_CULL_FACE);   // 打开背面剔除
  (*********)
  Application.OnIdle := Display;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DeactivateRenderingContext; // 解绑 DC, RC
  wglDeleteContext(RC);       // 释放 RC
  ReleaseDC(Handle, DC);      // 释放 DC
end;

procedure TForm1.FormResize(Sender: TObject);
const
  NearClipping = 1;
  FarClipping = 1000;
begin
  glViewport(0, 0, ClientWidth, ClientHeight); // 设置视窗
  glMatrixMode(GL_PROJECTION); // 更改投影矩阵
  glLoadIdentity; // 设置当前矩阵为单位阵
  gluPerspective(45.0, ClientWidth / ClientHeight, NearClipping, FarClipping); // 设置场景大小
  glMatrixMode(GL_MODELVIEW); // 更改模型视图矩阵
  glLoadIdentity; // 设置当前矩阵为单位阵
end;

end.

