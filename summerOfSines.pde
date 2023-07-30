// This program will be drawing epicycles 

int n = 31; // Number of circles
// This is the time variable f(t); 
float globalTime = 0; 


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
        // Flip the y coordinate
        this.y = height - y;
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
        tint(255, 255, 255, 100);
        line(this.x, this.y, this.x + xOff, this.y - yOff);
        // Draw arrow
        float arrowSize = 7;
        float x1 = this.x + xOff;
        float y1 = this.y - yOff;
        float x2 = this.x + xOff - arrowSize * cos(theta + PI/6);
        float y2 = this.y - yOff + arrowSize * sin(theta + PI/6);
        float x3 = this.x + xOff - arrowSize * cos(theta - PI/6);
        float y3 = this.y - yOff + arrowSize * sin(theta - PI/6);
        
        stroke(255, 255, 255);
        fill(255, 255, 255, 10);  
        triangle(x1, y1, x2, y2, x3, y3);
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
        return this.y - yOff;
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
float[][] c; // = {{10,10}, {10,90}, {10,10}, {40,40}, {90,90}, {40,40}, {30,70}, {40,40}, {40,40}, {40,40}, {40,40}}; 

// List of the circles
circ[] cList;

// path 
ArrayList<float[][]> path = new ArrayList<float[][]>();
ArrayList<float[][]> tracer = new ArrayList<float[][]>();

void readPath(){
    String[] lines = loadStrings("path.txt");
    for (int i = 0; i < lines.length; i++){
        String[] temp = split(lines[i], " ");
        float[][] temp2 = {{float(temp[0]), float(temp[1])}};
        path.add(temp2);
    }
}

void calculateConstant(int index){
    float dt = (2 * PI) / path.size();
    float sumReal = 0;
    float sumImaginary = 0;
    int index2 = index - (n / 2);
    print(index2 + "\n");
    float realSum = 0; 
    float imaginarySum = 0;
    for (int i = 0; i < path.size(); i++){
        float realF = path.get(i)[0][0];
        float imaginaryF = path.get(i)[0][1];
        float t = i * dt;
        // f(t) * e ^ (-i * n * t), n is index2
        // We expnd the avove
        // f(t) * cos(n * t) - i * f(t) * sin(n * t)
        // Expand f(t) to its real and imaginary parts
        // (real + imaginary) * cos(n * t) - i * (real + imaginary) * sin(n * t)\
        // We can now split this into two integrals
        // real * cos(n * t) - i *rreal * sin(n * t) + imaginary * cos(n * t) - i * imaginary * sin(n * t)
        realSum +=  (realF * cos(index2 * t) + imaginaryF * sin(index2 * t)) * dt;
        imaginarySum += (-realF * sin(index2 * t) + imaginaryF * cos(index2 * t)) * dt;
    }

    // Divide by 2pi
    realSum /= (2 * PI);
    imaginarySum /= (2 * PI);
    c[index][0] = realSum;
    c[index][1] = imaginarySum;
}

void setup(){
    size(1000, 1000);
    stroke(255);
    // This is where yo uwould alculate the constants

    // Read the path from the file
    readPath();
    c = new float[n][2];
    // Calculate the constants
    for (int i = 0; i < n; i++){
        calculateConstant(i);
    }

    cList = new circ[n];
    // Set values for the circles with calculated constants
    for (int i = 0; i < n; i++){
        // i is the n value so we have to center it so that when i = 6, velocity is 0
        cList[i] = new circ(0, 0, c[i][0], c[i][1], i - (n / 2));
    }
}

void draw(){ 
    // Iterate from 0 to 2pi
    background(0);

    // Draw the intended path 
    stroke(255, 0, 0, 100);
    for (int i = 0; i < path.size() - 1; i++){
        line(500+ path.get(i)[0][0], 500 - path.get(i)[0][1], 500+path.get(i+1)[0][0], 500 - path.get(i+1)[0][1]);
    }

    // Draw all circles
    // Initial point is 
    float prevX = 500; 
    float prevY = 500;

    for (int i = 0; i < n; i++){
        cList[i].x = prevX;
        cList[i].y = prevY;
        tint(255, 255, 255, 150);
        stroke(70); 
        circle(prevX, prevY, cList[i].radius*2);
        

        
        stroke(255, 255, 255, 100);
        noFill();
        cList[i].drawCirc(globalTime);
        
        prevX = cList[i].getXEnd(globalTime);
        prevY = cList[i].getYEnd(globalTime);

        if (i == n-1){
            float[][] temp = {{prevX, prevY}};
            tracer.add(temp);
        }
        if (path.size() > 1000){
            tracer.remove(0);
        } 
    }

    // Draw the path
    for (int i = 0; i < tracer.size()-1; i++){
        float[][] temp = tracer.get(i);
        float[][] temp2 = tracer.get(i+1);
        line(temp[0][0], temp[0][1], temp2[0][0], temp2[0][1]);
    }




    if (globalTime > 2 * PI){
        globalTime = 0;
    }
    if (keyPressed){
        if (key == ' '){
            globalTime += 0.01;
        }
        //  Rest
        if (key == 'r'){
            globalTime = 0;
            // reset path 
            tracer = new ArrayList<float[][]>();
        }
    }

}