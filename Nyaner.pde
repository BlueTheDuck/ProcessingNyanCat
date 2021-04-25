import processing.video.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
/*

N    N N     N    NN    N    N NNNNNNN NNNNN      N     N  4    4
NN   N  N   N    N  N   NN   N N       N    N     N     N  4    4
N N  N   N N    N    N  N N  N N       N    N     N     N  4    4
N  N N    N    NNNNNNNN N  N N NNNN    NNNNN       N   N   4444444
N   NN    N    N      N N   NN N       N    N       N N         4
N    N    N    N      N N    N NNNNNNN N     N       N          4



*/

//import apwidgets.*;

////***Variables de datos no-processing***////
//GIFs
GIFplayer nyanCat;
GIFplayer[] tail;
GIFplayer[] stars;
//Sonido
Minim minim;
AudioPlayer bgm;
//Video
Capture cam;

//Variables
int tailLength;
int shaderUse = 0;
int maxStars = 8;
int cams = 0;

boolean allowShader = true;
boolean escMenu = false;
boolean sound = true;
boolean camsScanned = false;
boolean camAval = false;

String nyanedFor;
String suitableCam;
String[] shaderNames;
String[] shaderProperties;

PShader[] shader;

PImage image;
PImage def;//Default in case camAval==false

PGraphics menu;
PGraphics game;

PFont silkscreen;

XML shadersData;

void setup() {
  size(800,600,P2D);
  //fullScreen(P2D);
 
  /*   Data   */
  nyanedFor = "0";
  
  shadersData = loadXML("Shaders.xml");
  XML[] shadersXMLChildren = shadersData.getChildren("shader");
  shader = new PShader[shadersXMLChildren.length];
  shaderNames = new String[shadersXMLChildren.length];
  shaderProperties = new String[shadersXMLChildren.length];
  for (int i=0;i<shadersXMLChildren.length;i++) {
    shader[i] = loadShader(shadersXMLChildren[i].getChildren("path")[0].getContent());
    shaderNames[i] = shadersXMLChildren[i].getChildren("name")[0].getContent();
    if (shadersXMLChildren[i].getChildren("properties").length>0) {
      shaderProperties[i] = shadersXMLChildren[i].getChildren("properties")[0].getContent();
      if(shadersXMLChildren[i].getChildren("image").length>0) {
        println("Shader "+i+" has <image>");
        XML imageProps = shadersXMLChildren[i].getChildren("image")[0];
        shaderProperties[i] = shaderProperties[i].replace("image","image:"+trim(imageProps.getChildren("path")[0].getContent())+":"+trim(imageProps.getChildren("type")[0].getContent()));
        println("Loading image "+imageProps.getChildren("path")[0].getContent());
        image = loadImage(imageProps.getChildren("path")[0].getContent(),imageProps.getChildren("type")[0].getContent());
      }
      if(match(shaderProperties[i],"camera")!=null) {
        println("Shader #"+i+" ("+shaderNames[i]+") wants to use a camera");
        if(!camsScanned) {
          String[] cameras = Capture.list();
          cams = cameras.length;
          if(cams==0) {
            println("Warning: Cameras found: "+cams);
            println("'default.png' will be used as input for cam");
            def = loadImage("default.png");
          } else {
            camAval = true;
            println("Cameras found: "+cams);
            for(String oneCam:cameras) {
              println(">>"+oneCam);
              if(match(oneCam,"800x600")!=null) {
                 suitableCam = oneCam;
                 println("Suitable cam found: "+suitableCam);
              }
            }
            if(suitableCam=="") {
              suitableCam = cameras[0];
              println("No suitable cam found, using "+suitableCam);
            }
            cam = new Capture(this,suitableCam);
            cam.start();
          }
        }
      }
    } else {
      shaderProperties[i] = "";
    }
    println(shaderProperties[i]);
  }
  
  /*   Graficos   */
  nyanCat = new GIFplayer("Nyan/frame","png",12,2);
  tail = new GIFplayer[int(width/336)+1];
  for (int i=0;i<tail.length;i++) {
    tail[i] = new GIFplayer("Tail/frame","png",2,6);
  }
  tailLength = tail[0].getSize()[0];
  print("tailLength = "+tailLength+"\n");
  stars = new GIFplayer[maxStars];
  for(int i=0;i<maxStars;i++) {  
    stars[i] = new GIFplayer("nyanStars/f","png",6,2);
    stars[i].setFrame(int(random(7)));
  }
  
  frameRate(24);
  
  menu = createGraphics(width,height);
  game = createGraphics(width,height);
  
  /*   Sonido   */
  minim = new Minim(this);
  bgm = minim.loadFile("nyan.mp3",2048);
  //bgm.play();
  //bgm.pause();*/
  println(dataPath("nyan.mp3"));
  /*bgm = new APMediaPlayer(this);
  bgm.setMediaFile(dataPath("nyan.mp3"));
  bgm.start();
  bgm.setVolume(1.0,1.0);*/
  
  /*   Fuente   */
  silkscreen = loadFont("Silkscreen-32.vlw");
  textFont(silkscreen);
  
}

void draw() {
  //bgm.pause();
  updateShader();
  
  if (bgm.loopCount()<2&&sound) {bgm.loop(3);}
  
  if (!escMenu) {
    drawGame();
  } else if (escMenu) {
    drawMenu();
  }
  //Termina de dibujar el menu
  
  //Carga grafica del menu y el juego
  /*if (!escMenu) {
    image(game,0,0);
  } else {
    image(menu,0,0);
  }*/
  image(game,0,0);
  if(escMenu) {
    image(menu,0,0);
  }
  if(allowShader){filter(shader[shaderUse]);}
}

void keyPressed() {
  if (key==ESC) {
    key = 0;
    escMenu = !escMenu;
    /*if (!escMenu) {
      bgm.play(bgm.position());
    } else if (escMenu) {
      bgm.pause();
    }*/
    if(escMenu) {
      bgm.pause();
    } else if(sound) {
      bgm.play(bgm.position());
    }
  }
}

void keyReleased() {

}

void keyTyped() {
  if (escMenu) {
    switch(key) {
      case 'p':
        sound = !sound;
        if(sound) {bgm.play();}else{bgm.pause();}
        println("sound = "+sound);
        break;
      case 's':
        shaderUse++;
        if(shaderUse==shader.length) {shaderUse=0;}
        println(shaderUse);
        break;
      case 'r':
        shader[shaderUse] = loadShader(shadersData.getChildren("shader")[shaderUse].getChildren("path")[0].getContent());
        println("Reloading from: "+shadersData.getChildren("shader")[shaderUse].getChildren("path")[0].getContent());
        if (match(shaderProperties[shaderUse],"image")!=null) {
          println("Found image in <properties>");
          String[] saProps = shaderProperties[shaderUse].split(";");
          for(String s:saProps) {
            if(match(s,"image")!=null) {
              println("Found image properties");
              String[] saImageProps = s.split(":");
              println("Reloading image "+saImageProps[1]+" ("+saImageProps[2]+")");
              image = loadImage(saImageProps[1],trim(saImageProps[2]));
            }
          }
        }
        break;
      default:
        println(key);
    }
    menu.background(#0F4D8F);
    image(menu,0,0);
    menu.background(#0F4D8F,0);
    image(menu,0,0);
    image(game,0,0);
    if(allowShader){filter(shader[shaderUse]);}
  } 
}

/*void onDestroy() {
  super.onDestroy();
  if(bgm!=null) {
    bgm.release();
  }
}*/

void drawGame() {  
  //Dibujar juego
  game.beginDraw();
  game.background(#0F4D8F);
  
  //*Draw star*//
  for(int i=0;i<maxStars;i++) {
    if(stars[i].Frame==5) {
      stars[i].drawGIF(random(width),random(height),game);
    } else {
      float[] lastXY = stars[i].getLastXY();
      stars[i].drawGIF(lastXY[0]-12,lastXY[1],game);
    }
  }
  
  for (int i=0;i<tail.length;i++) {
    tail[i].drawGIF(mouseX-nyanCat.getSize()[0]-(tail[i].getSize()[0]-2)*(i)-nyanCat.getSize()[0]/2,mouseY-nyanCat.getSize()[1]/2+6,game);
    if(i>0) {tail[i].setFrame(tail[0].getFrame());}
  }
  nyanCat.drawGIF(mouseX-nyanCat.getSize()[0]/2,mouseY-nyanCat.getSize()[1]/2,game);
  game.textFont(silkscreen);
  game.text("You've nyaned for",width/2-(textWidth("You've nyaned for")/2),height/6*5);
  nyanedFor = (int(floor(millis()/100.0))/10.0+"");
  game.text(nyanedFor,width/2-(textWidth(nyanedFor)/2),height/6*5+32);
  game.text("seconds",width/2-(textWidth("seconds")/2),height/6*5+64);
  game.endDraw();
  //Termina de dibujar el juego
}

void drawMenu() {
  //Dibuja el menu
  menu.beginDraw();
  menu.background(#0F4D8F,0);
  menu.textSize(32);
  menu.textFont(silkscreen);
  menu.text("Pausa",width/2-textWidth("Pausa")/2,height/2-16);
  
  float widthToUse = 0;
  float widthToNotUse = 0;
  String[] namesToUse = new String[5]; 
  int mod = 0;
  for(int i=-2;i<3;i++) {
    if (shaderUse+i<0) {
      mod = shaderUse+i+shader.length;
    } else if(shaderUse+i>shader.length-1) {
      mod = shaderUse+i-shader.length;
    } else {
      mod = shaderUse+i;
    }
    if(i==0) {
      namesToUse[i+2] = shaderNames[mod]+">";
    } else {
      namesToUse[i+2] = shaderNames[mod];
    }
    widthToUse+=textWidth(shaderNames[mod]);
  }
  widthToNotUse = (width-widthToUse)/6;
  int cursorX = 0;
  for(int i=0;i<5;i++) {
    cursorX+=widthToNotUse;
    menu.text(namesToUse[i],cursorX,32);
    cursorX+=textWidth(namesToUse[i]);
  }
  
  menu.text("S",width-32,height-32);
  if(!sound) {
    menu.fill(255,0,0);
    menu.text("X",width-32,height-32);
    menu.fill(255,255,255);
  }
  
  menu.endDraw();
  //image(menu,0,0);
}

void updateShader() {
  String props = shaderProperties[shaderUse];  
  if(match(props,"time")!=null) {
    shader[shaderUse].set("time",millis()/1000.0);
  }
  if(match(props,"resolution")!=null) {
    shader[shaderUse].set("resolution",float(width),float(height));
  }
  if(match(props,"mouse")!=null) {
    shader[shaderUse].set("mouse",float(mouseX),float(mouseY));
  }
  if(match(props,"image")!=null) {
    shader[shaderUse].set("image",image);
  }
  if(match(props,"camera")!=null) {
    if(camAval)
      shader[shaderUse].set("camera",cam);
    else
      shader[shaderUse].set("camera",def);
  }
}

class GIFplayer {
  PImage[] framesImg;
  int[] gifSize;
  int Frames;
  int Frame = 0;
  float frmsTillNextFrame = 0;
  float frmDuration;
  float x,y;
  
  GIFplayer(String path, String suf, int frms, float frmduration) {
    frmDuration = frmduration;
    frmsTillNextFrame = frmDuration;
    gifSize = new int[2];
    framesImg = new PImage[frms];
    Frames = frms;
    String fullPath;
    for (int i=1;i<frms+1;i++) {
      fullPath = path+nf(i,1)+"."+suf;
      framesImg[i-1] = loadImage(fullPath);
    }
    gifSize[0] = framesImg[0].width;
    gifSize[1] = framesImg[0].height;
  }
  
  void drawGIF(float x, float y,PGraphics toDraw) {
    drawGIF(x,y,framesImg[0].width,framesImg[0].height,toDraw);
  }
  void drawGIF(float x, float y) {
    drawGIF(x,y,framesImg[0].width,framesImg[0].height);
  }
  void drawGIF(int x,int y) {
    drawGIF((float)x,(float)y);
  }
  void drawGIF(float tx, float ty, int w, int h) {
    /*image(framesImg[int(Frame)],x,y,w,h);
    if (Frame==Frames-1) {Frame = -1;}
    Frame++;*/
    frmsTillNextFrame--;
    if (frmsTillNextFrame<1) {Frame+=1;frmsTillNextFrame=frmDuration;}
    if (Frame>Frames-1) {Frame=0;}
    x = tx;
    y = ty;
    image(framesImg[Frame],x,y,w,h);
  }
  void drawGIF(float tx, float ty, int w, int h, PGraphics toDraw) {
    /*image(framesImg[int(Frame)],x,y,w,h);
    if (Frame==Frames-1) {Frame = -1;}
    Frame++;*/
    frmsTillNextFrame--;
    if (frmsTillNextFrame<1) {Frame+=1;frmsTillNextFrame=frmDuration;}
    if (Frame>Frames-1) {Frame=0;}
    x = tx;
    y = ty;
    toDraw.image(framesImg[Frame],x,y,w,h);
  }
  
  float[] getLastXY() {
    float[] xy = new float[2];
    xy[0] = x;
    xy[1] = y;
    return xy;
  }
  
  int[] getSize() {
    return gifSize;
  }
  
  float getAspectRatio() {
    return getSize()[0]/getSize()[1];
  }
  
  int getFrame() {
    return Frame;
  }
  
  void setFrame(int frame) {
    Frame = frame;
  }
  
}