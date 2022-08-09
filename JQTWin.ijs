NB. JQtWin - window driver usage
NB. get a bitmap and display as a background to a window

NB. the following sources were helpful to putting this code together:
NB. Bill Lam's answer on the Jprogramming forum (Displaying a PNG...):
NB. http://www.jsoftware.com/pipermail/programming/2018-April/050898.html
NB. https://code.jsoftware.com/wiki/User:Raul_Miller/OpenGL/Page2
NB. https://code.jsoftware.com/wiki/Guides/Window_Driver/Animation/Animated_JGL2
NB. 
   load '~addons/ide/qt/keys.ijs'
   require 'gl2'
   coinsert 'jgl2'
  
NB. panelize - Make panels out of a bitmap
NB. Raul Miller's solution
NB. (,seed){~($seed)#.($seed)|"1 ($target)#:i.$target
NB.   panelize1 =: {{(,y){~($y)#.($y)|"1 (x)#:i.x}}
NB. 
NB. Elijah Stone's solution
NB. panelize2 =: {{(0{x)$(1{x)$"1 y}}
NB. 
NB. I used panelize2 that I put into tacit form
panelize =: (0 {  [) $ ] $"1~ 1 {  [

mygenbmp =: {{(256*256*256*255)+(256*256*256|xoffset+i.x)+/ 256*256|yoffset+i.y}}

NB. runmywin - set up and start the window that has a toucan background
runmywin =: 3 : 0
NB.   b =: readimg_jqtide_ jpath '~addons/graphics/bmp/toucan.bmp'
   wd 'pc mywin;pn GenBitMapWin'
   wd 'cc g isidraw'
   
   NB. this sets the minimum window width and length
   NB. the window can not be resized below this minimum
NB.   wd 'set g minwh ', ":(|.$b)
   wd 'set g minwh ', ":10 10
   NB. pshow window driver call will send out a resize event
   NB. the rest of the code can be placed in the resize callback
   wd 'pshow'
   sys_timer_z_ =: mysystimehdlr_base_
   wd 'timer 100'
)

NB. minimal cleanup that needs to be done so far
cleanupmywin =: 3 : 0
wd 'timer 0'
wd 'pclose'
wd 'reset'
)

NB. mywin_close - parent close callback name
mywin_close =: cleanupmywin

NB. Child window callbacks
mywin_g_initialize=: 3 : 0
NB. load extensions, query glGetString, compile shader, setting up buffers, etc...
NB. since different versions of GLSL are incompatible with each other,
NB. it needs to query the version of GLSL here and execute different codes.
)

NB. resize callback
NB. by putting the panelize code here when ever a resize event
NB. is created by the window system the bitmap is expanded or 
NB. contracted to fill the background appropriately
mywin_g_resize=: 3 : 0
NB. size of widget changed
'w h' =. ". wd 'get g wh'

xoffset =: 0
yoffset =: 0
NB. c =: (h,w) panelize b
    c =: h mygenbmp w

   glsel 'g'
0
   glpixels 0 0, (|. $c), ,c
0
   wd 'pshow'

)

mywin_g_paint=: 3 : 0
NB. OpenGL stuff here
NB. draw on OpenGL context
NB.
NB. additional overlay:
NB. use gl2 commands to draw on top of OpenGL surface such as text
NB. these gl2 commands for OpenGL overlay are similar to regular gl2 commands
NB. but with prefix gl_ instead of gl, eg
NB. gl_clear, gl_text
NB. GL_DEPTH_TEST must be disabled for overlay otherwise invisible
)


mywin_g_char=: 3 : 0
if. (239 160 146 -: a. i. sysdata) do.
  smoutput 'Left Key pressed'
  return.
end.
if. (239 160 147 -: a. i. sysdata) do.
  smoutput 'Up Key pressed'
  return.
end.
if. (239 160 148 -: a. i. sysdata) do.
  smoutput 'Right Key pressed'
  return.
end.
if. (239 160 149 -: a. i. sysdata) do.
  smoutput 'Down Key pressed'
  return.
end.
smoutput 'Other key pressed'
)

update =: verb define
NB. any calculations needed by renderer
'w h' =. ". wd 'get g wh'
NB. xoffset =: xoffset + 1
yoffset =: yoffset + 1

NB. c=: 100 |."1 c
c =: h mygenbmp w
)

render =: verb define

NB. c =: (h,w) panelize b
   glsel 'g'
0
   glpixels 0 0, (|. $c), ,c
0
   glpaint''
   wd 'pshow'
)

NB. system timer handler
mysystimehdlr =: render @ update
