// This program will be drawing epicycles 

int n = 10; // Number of circles
// This is the time variable f(t); 
float globalTime = 0; 

boolean drawPath = false;

// Circle/Vector/Epicycle class 
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
    circ(float x, float y, float real, float imaginary, float v) {
        this.x = x;
        // Flip the y coordinate
        this.y = height - y;
        this.real = real;
        this.imaginary = imaginary;
        this.v = v;
        radius = sqrt(real * real + imaginary * imaginary);
        offset = atan2(imaginary, real);
    }
    
    void drawCirc(float time) {
        float theta = (v * time) + offset;
        float xOff = radius * cos(theta);
        float yOff = radius * sin(theta);
        // Add some thickness to the line
        strokeWeight(2);
        tint(255, 255, 255, 100);
        line(this.x, this.y, this.x + xOff, this.y - yOff);
        // Draw arrow
        float arrowSize = radius / 20 + 1;
        float x1 = this.x + xOff;
        float y1 = this.y - yOff;
        float x2 = this.x + xOff - arrowSize * cos(theta + PI / 6);
        float y2 = this.y - yOff + arrowSize * sin(theta + PI / 6);
        float x3 = this.x + xOff - arrowSize * cos(theta - PI / 6);
        float y3 = this.y - yOff + arrowSize * sin(theta - PI / 6);
        
        stroke(255, 255, 255);
        fill(255, 255, 255, 10);  
        triangle(x1, y1, x2, y2, x3, y3);
    }
    
    float getXEnd(float time) {
        float theta = (v * time) + offset;
        float xOff = radius * cos(theta);
        float yOff = radius * sin(theta);
        return this.x + xOff;
    }
    
    float getYEnd(float time) {
        float theta = (v * time) + offset;
        float xOff = radius * cos(theta);
        float yOff = radius * sin(theta);
        return this.y - yOff;
    }
    
    float getXcos(float time) {
        float theta = (v * time) + offset;
        float xOff = radius * cos(theta);
        return xOff; 
    }
    
    float getYsin(float time) {
        float theta = (v * time) + offset;
        float yOff = radius * sin(theta);
        return yOff; 
    }
}

// This will be defining our function f(t)
float[] f; 
// List of the constants used in the fourier series
float[][] c;
// List of the circles
circ[] cList;

// path 
ArrayList<float[][]> path = new ArrayList<float[][]>();
ArrayList<float[][]> tracer = new ArrayList<float[][]>();

void readPath() {
    String[] lines = loadStrings("path.txt");
    for (int i = 0; i < lines.length; i++) {
        String[] temp = split(lines[i], " ");
        if (temp.length != 2) {
            continue;
        }
        float[][] temp2 = {{float(temp[0]), float(temp[1])} };
        path.add(temp2);
    }
}

void calculateConstant(int index) {
    float dt = (2 * PI) / path.size();
    float sumReal = 0;
    float sumImaginary = 0;
    int index2 = index - (n / 2);
    float realSum = 0; 
    float imaginarySum = 0;
    for (int i = 0; i < path.size(); i++) {
        float realF = path.get(i)[0][0];
        float imaginaryF = path.get(i)[0][1];
        float t = i * dt;
        realSum += (realF * cos(index2 * t) + imaginaryF * sin(index2 * t));
        imaginarySum += ( -realF * sin(index2 * t) + imaginaryF * cos(index2 * t));
    }
    
    // Divide by 2pi
    realSum /= (2 * PI);
    imaginarySum /= (2 * PI);
    realSum *= dt; 
    imaginarySum *= dt;
    c[index][0] = realSum;
    c[index][1] = imaginarySum;
}

void setup() {
    size(1000, 1000);
    if (!drawPath) {
        stroke(255);
        
        // Read the path from the file
        readPath();

        addExtraPoints();
        regularInterval(); 
        
        c = new float[n][2];
        // Calculate the constants
        for (int i = 0; i < n; i++) {
            calculateConstant(i);
        }
        
        cList = new circ[n];
        // Set values for the circles with calculated constants
        for (int i = 0; i < n; i++) {
            // i is the n value so we have to center it so that when i = 6, velocity is 0
            cList[i] = new circ(0, 0, c[i][0], c[i][1], i - (n / 2));
        }
        print("Done calculating constants");
    } else {
        background(0);
        stroke(255);
    }
}

void addExtraPoints() {
    if (path.size() > n){
        return;  
    }
    // This function reads the path.txt file and add extra points between each point using linear interpolation
    // This is to make the path smoother
    ArrayList<float[][]> temp = new ArrayList<float[][]>();
    
    readPath();

    // find midpoint between each pair of poitns and then add into list 
    for (int i = 0; i < path.size() - 1; i++) {
        float[][] temp2 = {{(path.get(i)[0][0] + path.get(i + 1)[0][0]) / 2, (path.get(i)[0][1] + path.get(i + 1)[0][1]) / 2}};
        temp.add(path.get(i));
        temp.add(temp2);
    }
    
    path = temp;
    
    // write to file
    PrintWriter output = createWriter("path.txt");
    for (int i = 0; i < path.size(); i++) {
        output.println(path.get(i)[0][0] + " " + path.get(i)[0][1]);
    }
    output.flush();
    output.close();

    // if the count is less than n then add more points
    if (path.size() < n) {
        addExtraPoints();
    }

}

void regularInterval(){
    ArrayList <float[][]> temp = new ArrayList<float[][]>();
    float distance = 0; 
    for (int i = 0; i < path.size()-1; i++){
        distance += sqrt(pow(path.get(i)[0][0] - path.get(i+1)[0][0], 2) + pow(path.get(i)[0][1] - path.get(i+1)[0][1], 2));
        if (distance > 1){
            temp.add(path.get(i));
            distance = 0;
        }
    }
    path = temp;
}


void draw() {     
    // Display the number of circles
    if (drawPath) {
        if (mousePressed) {
            float[][] temp = {{mouseX - 500, 500 - mouseY} };
            noFill(); 
            ellipse(mouseX, mouseY, 3, 3);
            // Also draw the lines 
            if (path.size() == 0) {
                path.add(temp);
            } if (path.get(path.size() - 1)[0][0] != temp[0][0] || path.get(path.size() - 1)[0][1] != temp[0][1]) {
                path.add(temp);
                // draw line from current to prevoius
                line(path.get(path.size() - 2)[0][0] + 500, 500 - path.get(path.size() - 2)[0][1], temp[0][0] + 500, 500 - temp[0][1]);
            }
        }
        if (keyPressed) {
            if (key == 's') {
                String[] lines = new String[path.size()];
                for (int i = 0; i < path.size(); i++) {
                    lines[i] = str(path.get(i)[0][0]) + " " + str(path.get(i)[0][1]);
                }
                saveStrings("path.txt", lines);
            }
            drawPath = false; 
            setup(); 
        }
    } else {
        // Iterate from 0 to 2pi
        background(0);
        fill(255);
        textSize(32);
        text("Circles: " + str(n), 10, 30);
        // Display the path length
        fill(255);
        textSize(32);
        text("Points: " + str(path.size()), 10, 70);

        // Draw the intended path 
        stroke(255, 0, 0, 100);
        for (int i = 0; i < path.size() - 1; i++) {
            strokeWeight(1); 
            line(500 + path.get(i)[0][0], 500 - path.get(i)[0][1], 500 + path.get(i + 1)[0][0], 500 - path.get(i + 1)[0][1]);
            // Draw the points
            strokeWeight(2);
            point(500 + path.get(i)[0][0], 500 - path.get(i)[0][1]);
        }
        
        // Draw all circles
        // Initial point is 
        float prevX = 500; 
        float prevY = 500;
        
        for (int i = 0; i < n; i++) {
            cList[i].x = prevX;
            cList[i].y = prevY;
            tint(255, 255, 255, 150);
            stroke(70); 
            noFill(); 
            circle(prevX, prevY, cList[i].radius * 2);
            
            stroke(255, 255, 255, 100);
            noFill();
            cList[i].drawCirc(globalTime);
            
            prevX = cList[i].getXEnd(globalTime);
            prevY = cList[i].getYEnd(globalTime);
            
            if (i == n - 1) {
                float[][] temp = {{prevX, prevY} };
                tracer.add(temp);
            }
            if (tracer.size() > 1000 && tracer.size() != 0) {
                tracer.remove(0);
            } 
        }
        
        // Draw the path
        for (int i = 0; i < tracer.size() - 1; i++) {
            float[][] temp = tracer.get(i);
            float[][] temp2 = tracer.get(i + 1);
            line(temp[0][0], temp[0][1], temp2[0][0], temp2[0][1]);
        }
        
        if (globalTime > 2*PI) {
            globalTime = 0;
        }
    
        if (keyPressed) {                         
            if (key == ' ') {
                globalTime += 0.02;
            }
            //  Rest
            if (key == 'r') {
                globalTime = 0;
                // reset path 
                tracer = new ArrayList<float[][]>();
            }
            if (key == 'i'){
                // Increase N and reset everything
                n+=4;
                path = new ArrayList<float[][]>();
                tracer = new ArrayList<float[][]>();
                background(0);
                globalTime = 0; 
                delay(500);
                setup(); 

            }

            // Exporting to a desmos graph, to a file called desmos.txt
            if (key == 'e'){
                // Export all the sine functions to a file
                String xFunc = "f_{x}\\left(t\\right)= "; 
                String yFunc = "f_{y}\\left(t\\right)= -(";
                PrintWriter output = createWriter("desmos.txt");
                for (int i = 0; i < n; i++){
                    // create variable name 
                    String varName = "a" + str(i);
                    // create the point (prev + cos(theta), prev + sin(theta))
                    String sign; 
                    if (cList[i].offset < 0) {
                        sign = "-";
                    } else {
                        sign = "+";
                    }
                    if (i != n-1){
                    xFunc += " (" + nf(cList[i].radius,10,20) + ") \\cdot cos((" + str(i-(n/2)) + "\\cdot t) - (" + nf(cList[i].offset, 3, 20) + ")) + ";
                    yFunc += " (" + nf(cList[i].radius,10,20) + ") \\cdot sin((" + str(i-(n/2)) + "\\cdot t) - (" + nf(cList[i].offset, 3, 20) + ")) + ";
                    } else {
                        xFunc += " (" + nf(cList[i].radius,10,20) + ") \\cdot cos(" + str(i-(n/2)) + "\\cdot (t - (" + nf(cList[i].offset, 3, 20) + ")))";
                        yFunc += " (" + nf(cList[i].radius,10,20) + ") \\cdot sin(" + str(i-(n/2)) + "\\cdot (t - (" + nf(cList[i].offset, 3, 20) + "))))";
                    }
                }
                output.println(xFunc);
                output.println(yFunc);
                output.flush();
                output.close();
            }
        }
        if (mousePressed) {
            // redraw path
            background(0);
            path = new ArrayList<float[][]>();
            tracer = new ArrayList<float[][]>();
            drawPath = true;
            setup();
        }
    }
}