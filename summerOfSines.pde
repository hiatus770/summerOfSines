// This program will be drawing epicycles 

// Circle class 
class circ {
    // Coordinates of the points 
    float x, y; 
    // Describes the starting point, and the radius of the circle 
    float real, imaginary;
    // Radius is calculated from the real and imaginary parts
    float radius; 
    float v; // Velocity    
    float offset; 

    // Circles in the form (real + imaginary) * e ^ (v (i * theta)) 
    circ(float x, float y, float real, float imaginary, float v){
        this.x = x;
        this.y = y;
        this.real = real;
        this.imaginary = imaginary;
        this.v = v;
        radius = sqrt(real * real + imaginary * imaginary);
        offset = atan2(imaginary, real);
    }

    void drawCirc(float time){
        float theta = (v * time) + offset;
        float xOff = radius * cos(theta);
        float yOff = radius * sin(theta);
        line(this.x, this.y, this.x + xOff, this.y + yOff);
        if (v == 0){
            print("X: " + this.x + " Y: " + this.y + " X offset: " + (xOff + x) + " Y offset: " + (yOff + y) + "\n"); 
        }
    }

    float getXEnd(float time){
        float theta = (v * time) + offset;
        float xOff = radius * cos(theta);
        float yOff = radius * sin(theta);
        return this.x + xOff;
    }

    float getYEnd(float time){
        float theta =(v * time) + offset;
        float xOff = radius * cos(theta);
        float yOff = radius * sin(theta);
        return this.y + yOff;
    }

    float getXcos(float time){
        float theta = (v * time) + offset;
        float xOff = radius * cos(theta);
        return xOff; 
    }

    float getYsin(float time){
        float theta = (v * time) + offset;
        float yOff = radius * sin(theta);
        return yOff; 
    }
}

// This will be defining our function f(t)
float[] f; 
// List of the constants used in the fourier series
// Some random values for now  
float[][] c = {{10,10}, {10,90}, {10,10}, {40,40}, {20,10}, {0,10}, {30,1}, {40,40}, {40,40}, {40,40}, {40,40}}; 

// List of the circles
circ[] cList;

// path 
ArrayList<float[][]> path = new ArrayList<float[][]>();

void setup(){
    size(1000, 1000);
    stroke(255);
    // This is where yo uwould alculate the constants

    cList = new circ[11];
    // Set values for the circles with calculated constants
    for (int i = 0; i < 11; i++){
        // i is the n value so we have to center it so that when i = 6, velocity is 0
        cList[i] = new circ(250, 250, c[i][0], c[i][1], i-5);
    }

}


// This is the time variable f(t); 
float globalTime = 0; 


void draw(){ 
    // Iterate from 0 to 2pi
    background(0);

    // Draw all circles
    float prevX = 500;  
    float prevY = 500; 

    for (int i = 0; i < 11; i++){
        cList[i].x = prevX;
        cList[i].y = prevY;

        if (cList[i].v == 0){
            stroke(25, 255, 0);
        } else {
            stroke(255);
        }

        cList[i].drawCirc(globalTime);
        prevX = cList[i].getXEnd(globalTime);
        prevY = cList[i].getYEnd(globalTime);

        if (i == 10){
            float[][] temp = {{prevX, prevY}};
            path.add(temp);
        }
        if (path.size() > 1000){
            path.remove(0);
        } 
    }

    // Draw the path
    for (int i = 0; i < path.size()-1; i++){
        float[][] temp = path.get(i);
        float[][] temp2 = path.get(i+1);
        line(temp[0][0], temp[0][1], temp2[0][0], temp2[0][1]);
    }




    if (globalTime > 2 * PI){
        globalTime = 0;
    }
    globalTime += 0.01;

}