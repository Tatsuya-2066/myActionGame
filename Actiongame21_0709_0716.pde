abstract class Background {
  
  abstract void display();
}

abstract class MovableShape {
  float x, y;
  
  abstract void display();
  
  abstract void move();
}

//背景クラス
class Background_stars extends Background{
  int number_of_stars = 30;
  int[] starsX = new int[number_of_stars], starsY = new int[number_of_stars];
  
  Background_stars() {
    for(int i = 0; i < starsX.length; i++) {
      starsX[i] = int(random(50, width - 50));
      starsY[i] = int(random(50, height - 50));
    }
  }
  
  void display() {
    background(0);
    for(int i = 0; i < starsX.length; i++) {
      fill(255, 255, 0);
      rect(starsX[i], starsY[i], 5, 5);
    }
  }
}

// 足場クラス
class Floor extends MovableShape{
  float x = 50, y = 50, floorX = 100, floorY = 10, dx = 5;
  
  Floor(float x0, float y0, float floorX0, float floorY0) {
    floorX = floorX0;
    floorY = floorY0;
    x = x0;
    y = y0;
    do {
      dx = random(-5, 5);
    } while(dx <= 3.0 && dx >= -2.0);
  }
  
  void display() {
    fill(255);
    rect(x, y, floorX, floorY);
  }
  
  void move() {
    x += dx;
    if (x + floorX > width || x < 0) {
      dx *= -1;
    }
  }
}

// ボールクラス
class Ball extends MovableShape{
  float d = 20, x = width / 2, y = 700, dx = 10, dy = 10;
  float g = 0.20, jump_speed = -8, tmpY = jump_speed, fall_speed = 0, fall_speed0 = fall_speed;
  boolean jump = false, ball_landing = false;
  
  Ball(float x0, float y0) {
    x = x0;
    y = y0;
  }
  
  void display() {
    noStroke();
    fill(255, 0, 0);
    ellipse(x, y, d, d);
  }
  
  void move() {
    if (keyPressed) {
      switch(keyCode) {
      case LEFT:
        x -= dx;
        break;
      case RIGHT:
        x += dx;
        break;
      }
    }
  }
  
  void jump() {
    if(jump_speed <= 8) {
      jump_speed += g;
    }
    y += jump_speed;
  }
  
  void fall() {
    if(fall_speed <= 8) {
      fall_speed += g;
    }
    y += fall_speed;
  }
}

class GoalFloor extends Floor { 
  
  GoalFloor(float x0, float y0, float floorX0, float floorY0) {
    super(x0, y0, floorX0, floorY0);
  }
  
  void goal() {
    fill(255, 0, 0);
    textSize(64);
    text("Congratulations!", width / 2, height / 2);
    noLoop();
  }
}

class Flag {
  float x = 10, y = 10;
  
  Flag(float x0, float y0) {
    x = x0;
    y = y0;
  }
  
  void display() {
    stroke(255);
    fill(0, 255, 0);
    triangle(x, y, x + 12, y + 5, x, y + 10);
    line(x, y + 10, x, y + 20);
  }
}

Background_stars bg_s;
Floor[] floors = new GoalFloor[7];
Ball b;
Flag f;
boolean ball_landing = false; // ボールが着地している状態
boolean gameStart = false;

void setup() {
  size(800, 800);
  bg_s = new Background_stars();
  for (int i = 0; i < floors.length; i++) {
    floors[i] = new GoalFloor(random(width - 200 - 23 * i), height - 100 - i * 110, 200 - 23 * i, 10);
  }
  b = new Ball(width / 2, height - 10);
  f = new Flag(floors[6].x + floors[6].floorX / 2, floors[6].y - 20);
  ball_landing = false;
}

void draw() {
  if(!gameStart) {
    draw_startScreen();
  } else {
    bg_s.display();
    // 足場
    for (int i = 0; i < floors.length; i++) {
      floors[i].display();
      floors[i].move();
      // 足場の上側にボールが触れたらその場に着地する
      // 下側に触れると跳ね返される
      if(b.x > floors[i].x && b.x < floors[i].x + floors[i].floorX
      && b.y + b.d / 2 > floors[i].y && b.y + b.d / 2 < floors[i].y + floors[i].floorY) {
        b.jump = false;
        ball_landing = true;
        b.y = floors[i].y - b.d / 2;
        b.jump_speed = b.tmpY;
        b.fall_speed = b.fall_speed0;
      } else if(b.x > floors[i].x && b.x < floors[i].x + floors[i].floorX
      && b.y - b.d / 2 > floors[i].y && b.y - b.d / 2 < floors[i].y + floors[i].floorY) {
        b.y = floors[i].y + floors[i].floorY + b.d / 2;
        b.jump_speed = 0;
      }
    }
    
    // 旗
    f.x += floors[floors.length - 1].dx;
    
    // ゴール
    if(floors[floors.length - 1] instanceof GoalFloor) {
      GoalFloor gFloor = (GoalFloor) floors[floors.length - 1];
      if(b.x >= gFloor.x && b.x <= gFloor.x + gFloor.floorX
      && b.y == gFloor.y - b.d / 2) {
        gFloor.goal();
      }
    }
    
    // ボール
    b.display();
    b.move();
    if(b.jump) {
      b.jump();
    }
    // ボールが足場から外れたらボールが着地している判定を偽にする
    for(int i = 0; i < floors.length; i++) {
      if((b.x < floors[i].x || b.x > floors[i].x + floors[i].floorX)
      && b.y == floors[i].y - b.d / 2) {
        ball_landing = false;
      }
      if(ball_landing 
      && (b.x >= floors[i].x || b.x <= floors[i].x + floors[i].floorX)
      && b.y == floors[i].y - b.d / 2) {
        b.x += floors[i].dx;
      }
    }
    if(!ball_landing) {
      b.fall();
    }
    // ウィンドウの左右端にボールが達した時の処理
    if(b.x - b.d / 2 < 0) {
      b.x = b.d / 2;
    }
    if(b.x + b.d / 2 > width) {
      b.x = width - b.d / 2;
    }
    if(b.y + b.d / 2 > height) {
      b.jump = false;
      ball_landing = true;
      b.y = height - b.d / 2;
      b.jump_speed = b.tmpY;
      b.fall_speed = b.fall_speed0;
    }
    f.display();
  }
}

void draw_startScreen() {
  textSize(64);
  textAlign(CENTER);
  text("Climb!", width / 2, height / 2);
  fill(0);
  ellipse(width / 2, height / 4 * 3, 200, 200);
  fill(255);
  textSize(32);
  text("start", width / 2, height / 4 * 3 + 10);
  if(mousePressed) {
    if(dist(mouseX, mouseY, width / 2, height / 4 * 3) < 100) {
      gameStart = true;
    }
  }
}

void keyPressed() {
  if (ball_landing && key == ' ') {
    b.jump = true;
  }
}
