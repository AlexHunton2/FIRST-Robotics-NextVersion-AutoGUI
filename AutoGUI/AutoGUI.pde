enum commandType {Drive, Rotate, Eject}
enum driveDirection {d_FORWARD, d_BACKWARD, d_LEFT, d_RIGHT}
enum rotateDirection {r_LEFT, r_RIGHT}


//45 PIXELS = 1 FOOT
//3.75 PIXELS = 1 INCH
final static int inchesPixel = 4;
final double speedOffset = 2;
final double rotateOffset = 4;
final color specialColor = color(231, 81, 255);
final int robotWidth = 68;
final int robotHeight = 68;

int savedTime;
int startTime;

PImage field;
Robot robot;

class Command {
  private boolean isFinished;
  private commandType cmdType;
  
  private driveDirection d_direction;
  private rotateDirection r_direction;
  private double distance;
  private double speed;
  
  private float xgoal;
  private float ygoal;
  
  private color colorChange;
  
  private float anglegoal;
  
  //Drive Command
  Command(driveDirection direction, double distance, double speed) {
    this.d_direction = direction;
    this.distance = distance;
    this.speed = speed;
    this.cmdType = commandType.Drive;
  }
  
  //Rotate Command
  Command(rotateDirection direction, float angle, double speed) {
    this.r_direction = direction;
    if (this.r_direction == rotateDirection.r_RIGHT){
      this.anglegoal = angle;
    } else if (this.r_direction == rotateDirection.r_LEFT) {
      this.anglegoal = angle;
    }
    this.speed = speed;
    this.cmdType = commandType.Rotate;
  }
  
  //Color Change Commands (ie Eject)
  Command(commandType cmd, color colorChange) {
    this.cmdType = cmd;
    this.colorChange = colorChange;
  }
  
  void Drive() {
    if (this.cmdType == commandType.Drive) {
      if (this.xgoal == 0 || this.ygoal == 0) {
        int pixelDistance = convertInchToPixel(this.distance);
        switch (this.d_direction) {
          case d_FORWARD: 
            this.xgoal = round((pixelDistance*cos(-radians(robot.angle-90)) + robot.xpos));
            this.ygoal = round((pixelDistance*sin(-radians(robot.angle+90)) + robot.ypos));
            break;
          case d_BACKWARD: 
            this.xgoal = round((pixelDistance*cos(-radians(robot.angle+90)) + robot.xpos));
            this.ygoal = round((pixelDistance*sin(radians(robot.angle+90)) + robot.ypos));
            break;
          case d_LEFT: 
            this.xgoal = round((pixelDistance*cos(-radians(robot.angle-180)) + robot.xpos));
            this.ygoal = round((pixelDistance*sin(-radians(robot.angle)) + robot.ypos));
            break;
          case d_RIGHT: 
            this.xgoal = round((pixelDistance*cos(-radians(robot.angle)) + robot.xpos));
            this.ygoal = round((pixelDistance*sin(-radians(robot.angle-180)) + robot.ypos));
            break;
        }
      } else if(round(robot.xpos) == this.xgoal && round(robot.ypos) == this.ygoal) {
        robot.driveForward(0);
        this.xgoal = 0;
        this.ygoal = 0;
        this.isFinished = true;
      } else {
        //print("XGoal: " + xgoal + "\n");
        //print("X:" + (int)robot.xpos + "\n");
        //print("YGoal: " + ygoal + "\n");
        //print("Y:" + (int)robot.ypos + "\n");
        //print("\n");
        switch (this.d_direction) {
          case d_FORWARD: robot.driveForward(this.speed); break;
          case d_BACKWARD: robot.driveBackward(this.speed); break;
          case d_LEFT: robot.driveLeft(this.speed); break;
          case d_RIGHT: robot.driveRight(this.speed); break;
        }
      }
    } else {
      this.isFinished = false;
    }
  }
  
  void Rotate() {
    if (this.anglegoal == 0) {
      this.isFinished = true;
    } else if (inRange(round(this.anglegoal), round(robot.getAngle())-rotateOffset, round(robot.getAngle())+rotateOffset)) {
      robot.driveForward(0);
      robot.setAngle(this.anglegoal);
      this.anglegoal = 0;
      this.isFinished = true;
    } else {
      print("Angle Goal: " + this.anglegoal + "\n");
      print("Robot.Angle: " + robot.angle + "\n");
      switch(this.r_direction) {
        case r_LEFT: robot.rotateLeft(this.speed); break;
        case r_RIGHT: robot.rotateRight(this.speed); break;
      }
    }
  }
  
  void Eject() {
    if (startTime == 0) {
       startTime = millis();
    }
    int currentTime = millis();
    int timeDelay = 5000; // in milliseconds
    if ((timeDelay) <  (currentTime-startTime)) {
      robot.setColor(robot.getDefaultColor());
      startTime = 0;
      this.isFinished = true;
    } else if (!this.isFinished) {
      robot.setColor(this.colorChange);
    }
  }
  
  boolean IsFinished() {
    return isFinished;
  }
}

static int convertInchToPixel(double inches) {
  return round((float)(inches*inchesPixel));
}

static Boolean inRange(double value, double min, double max) {
  if (value >= min && value <= max) {
    return true;
  } else {
    return false;
  }
}

class Robot {
  private float xpos;
  private float ypos;
  private float angle;
  
  float xgoal;
  float ygoal;
  
  color robotColor;
  color defaultColor;
  
  PImage rawImg = loadImage("robot.png");
  PImage img = createImage(50, 50, 1);
  
  Robot(float x, float y) {
    this.xpos = x;
    this.ypos = y;
    this.robotColor = color(255, 0, 0);
    this.defaultColor = color(255, 0, 0);
    this.angle = 0;
  }
  
  Robot(color c, float x, float y) {
    this.xpos = x;
    this.ypos = y;
    this.robotColor = c;
    this.defaultColor = c;
    this.angle = 0;
  }
  
  Robot(color c, float x, float y, float angle) {
    this.xpos = x;
    this.ypos = y;
    this.robotColor = c;
    this.defaultColor = c;
    this.angle = -angle;
  }
  
  private void colorImg() {
    rawImg.loadPixels();
    img.loadPixels();
    for (int x= 0; x < rawImg.width; x++) {
      for (int y =0; y < rawImg.height; y++) {
        int loc = x + y * rawImg.width;
        if (rawImg.pixels[loc] == specialColor) {
          img.pixels[loc] = this.robotColor;
        }
      }
    }
    img.updatePixels();
  }
  
  void drawRobot() {
    stroke(0);
    fill(robotColor);
    rectMode(CENTER);
    translate(this.xpos, this.ypos);
    rotate(radians(angle));
    colorImg();
    image(img,-34,-34,robotWidth,robotHeight);
  }
  
  float getAngle() {
    if (this.angle > 360) {
      this.angle = 0;
    } else if (this.angle < 0) {
      this.angle += 360;
    }
    return angle;
  }
  
  void setAngle(float angle) {
    this.angle = angle;
  }
  
  void setColor(color Color) {
    this.robotColor = Color; 
  }
  
  color getColor() {
    return this.robotColor;
  }
  
  color getDefaultColor() {
    return this.defaultColor;
  }
  
  void driveForward(double speed) {
    speed = abs((float)speed)*speedOffset;
    this.ypos += speed*sin(radians(angle-90));
    this.xpos += speed*cos(radians(angle-90));
  }
  
  void driveBackward(double speed) {
    speed = abs((float)speed)*speedOffset;
    this.ypos -= speed*sin(radians(angle-90));
    this.xpos -= speed*cos(radians(angle-90));
  }
  
  void driveLeft(double speed) {
    speed = abs((float)speed)*speedOffset;
    this.ypos -= speed*sin(radians(angle));
    this.xpos -= speed*cos(radians(angle));
  }
  
  void driveRight(double speed) {
    speed = abs((float)speed)*speedOffset;
    this.ypos += speed*sin(radians(angle));
    this.xpos += speed*cos(radians(angle));
  }
  
  void rotateLeft(double speed) {
    speed = abs((float)speed) * rotateOffset;
    this.angle -= speed;
  }
  
  void rotateRight(double speed) {
    speed = abs((float)speed) * rotateOffset;
    this.angle += speed;
  }
}

ArrayList<Command> cmds = new ArrayList<Command>();

void initCommands() {
  cmds.add(new Command(commandType.Eject, color(0, 0, 255)));
  cmds.add(new Command(driveDirection.d_FORWARD, 47-18, 1));
  cmds.add(new Command(driveDirection.d_RIGHT, 85, 1));
  cmds.add(new Command(rotateDirection.r_LEFT, 270, 1));
  cmds.add(new Command(driveDirection.d_LEFT, 18, 1));
  cmds.add(new Command(commandType.Eject, color(255, 255, 0)));
}

void runCommands() {
  if (!cmds.isEmpty()) {
    Command cmd = cmds.get(0);
    if (cmd.IsFinished()) {
      cmds.remove(0);
    }
    switch (cmd.cmdType) {
      case Drive: cmd.Drive(); break;
      case Rotate: cmd.Rotate(); break;
      case Eject: cmd.Eject(); break;
    }
    
  }
}

void setup() {
  size(600, 600);
  loadPixels();
  robot = new Robot(color(255, 0, 0), 130, 500, 0);
  field = loadImage("field.png");
  initCommands();
  updatePixels();
}

void draw() {
  updatePixels();
  background(255);
  image(field, 0, 0, 540, 540);
  runCommands();
  robot.drawRobot();
}
