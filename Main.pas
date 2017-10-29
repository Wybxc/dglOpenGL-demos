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
  // 定义颜色常量
  A: array[1..3] of Single = (0, 0, 0);
  B: array[1..3] of Single = (2, 0, 0);
  C: array[1..3] of Single = (1, 0, 1.732); // (1, 0, Sqrt(3))
  P: array[1..3] of Single = (1, 1.732, 0.57735); // (1, Sqrt(3), 1 / Sqrt(3))
  // 定义顶点常量
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // 清屏

  // 绘图的操作在这里进行

  glLoadIdentity;          // 还原坐标系
  glTranslatef(0, 0, -5); // 坐标原点向屏幕内部移动5个单位长度

  glBegin(GL_QUADS); // 绘制连续的矩形
  begin              // 缩进辅助
    glColor3f(1, 1, 0); // OpenGL.Pen.Color := RGB(1, 1, 0);
    glVertex3f(0, 0, 0); // 第一个顶点(黄色), 位于坐标原点
    glColor3f(1, 1, 1); // OpenGL.Pen.Color := RGB(1, 1, 1);
    glVertex3f(1, 0, 0); // 第二、三、四个顶点(白色)
    glVertex3f(1, 1, 0);
    glVertex3f(0, 1, 0);
  end;
  glEnd;             // 结束绘图

  glTranslatef(-3, 0, 0); // 坐标原点向左移动3个单位长度

  glBegin(GL_TRIANGLES); // 绘制连续的三角形
  begin
    glColor3fv(@Red); // 使用指针, OpenGL.Pen.Color := ToColor(@Red);
    glVertex3fv(@A);
    glColorVertex(@Green, @B); // 定义简单方法 glColorVertex
    glColorVertex(@Blue, @C);
    // 底面完成
    glColorVertex(@Red, @A);
    glColorVertex(@Green, @B);
    glColorVertex(@White, @P);
    // 侧面完成 1/3
    glColorVertex(@Green, @B);
    glColorVertex(@Blue, @C);
    glColorVertex(@White, @P);
    // 侧面完成 2/3
    glColorVertex(@Blue, @C);
    glColorVertex(@Red, @A);
    glColorVertex(@White, @P);
    // 侧面完成
  end;               // 正四面体
  glEnd;             // 结束绘图

  SwapBuffers(DC); // 应用更改

  Done := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle); // 获得 DC
  if not InitOpenGL then
    raise Exception.Create('初始化 OpenGL 失败!'); // 初始化 OpenGL
  RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0); // 获得 RC
  ActivateRenderingContext(DC, RC); // 绑定 DC, RC
  (*********)
  glShadeModel(GL_SMOOTH);  // 启用颜色平滑

  glClearColor(0, 0, 0, 0); // 设置背景颜色

  glClearDepth(1.0);        // 设置深度缓存默认值
  glDepthFunc(GL_LEQUAL);   // 设置深度比较模式
  glEnable(GL_DEPTH_TEST);  // 打开深度测试

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST); // 告诉系统对透视进行最高质量修正

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
  (*********)
  glMatrixMode(GL_PROJECTION); // 更改投影矩阵
  glLoadIdentity; // 设置当前矩阵为单位阵
  gluPerspective(45.0, ClientWidth / ClientHeight, NearClipping, FarClipping); // 设置场景大小
  (*********)
  glMatrixMode(GL_MODELVIEW); // 更改模型视图矩阵
  glLoadIdentity; // 设置当前矩阵为单位阵
end;

procedure TForm1.glColorVertex(Color, Vertex: PGLfloat);
begin
  glColor3fv(Color);
  glVertex3fv(Vertex);
end;

end.

