// Combinación de código para visualización de datos tipo espiral
// Cambiar csv por el de video juegos

Table table;
int nSamples;
float[] rank;
float[] name;
float[] year;
float[] naSales;
float[] euSales;
float[] jpSales;
float[] globalSales;

// Variables para la visualización en espiral
float centroX, centroY;
float radioInterno = 100;
float rotacion = 0;
float maxRank = 0;
float maxNaSales = 0;
float maxEuSales = 0;
float maxJpSales = 0;
float maxGlobalSales = 0;

void setup() {
  size(1000, 1000);
  centroX = width / 2;
  centroY = height / 2;
  
  // Cargar los datos
  table = loadTable("vgsales.csv", "header");
  
  // Guardar el número de filas en la tabla
  nSamples = table.getRowCount();
  
  // Inicializamos los arrays
  rank = new float[nSamples];
  name = new float[nSamples];
  year = new float[nSamples];
  naSales = new float[nSamples];
  euSales = new float[nSamples];
  jpSales = new float[nSamples];
  globalSales = new float[nSamples];
  
  // Asignamos los datos
  for (int i = 0; i < nSamples; i++) {
    rank[i] = table.getFloat(i, "Rank");
    name[i] = table.getFloat(i, "Name");
    year[i] = table.getFloat(i, "Year");
    naSales[i] = table.getFloat(i, "NA_Sales");
    euSales[i] = table.getFloat(i, "EU_Sales");
    jpSales[i] = table.getFloat(i, "JP_Sales");
    globalSales[i] = table.getFloat(i, "Global_Sales");
    
    // Encontrar valores máximos para escalar correctamente
    // Toca corregir y terminar porque solo hay un circulo y 2 lineas
    if (rank[i] > maxRank) maxRank = rank[i];
    if (naSales[i] > maxNaSales) maxNaSales = naSales[i];
    //Tiene que haber un circulo para cada ranking
  }
  
  textAlign(CENTER, CENTER);
  frameRate(30);
}

void draw() {
  background(0);
  
  // Actualizar rotación
  rotacion += 0.002;
  
  // Dibujar círculo central
  fill(0);
  stroke(255);
  strokeWeight(2);
  ellipse(centroX, centroY, radioInterno * 2, radioInterno * 2);
  
  // Dibujar texto central
  fill(255);
  text("Uso de Apps\ny Batería", centroX, centroY);
  
  // Dibujar marcadores en el círculo
  dibujarMarcadores();
  
  // Dibujar datos como líneas en espiral
  dibujarDatosEspiral();
}

void dibujarMarcadores() {
  // Dibujamos marcadores alrededor del círculo
  textSize(12);
  for (int i = 0; i < 12; i++) {
    float angulo = map(i, 0, 12, 0, TWO_PI) + rotacion;
    float x = centroX + cos(angulo) * (radioInterno * 0.8);
    float y = centroY + sin(angulo) * (radioInterno * 0.8);
    
    fill(255);
    text(i+1, x, y);
  }
}

void dibujarDatosEspiral() {
  for (int i = 0; i < nSamples; i++) {
    // Usar el índice para distribuir los puntos alrededor del círculo
    float angulo1 = map(i, 0, nSamples, 0, TWO_PI) + rotacion;
    
    // PRIMERA SERIE DE DATOS: App Usage Time
    // Punto de inicio (círculo interior)
    float x1 = centroX + cos(angulo1) * radioInterno;
    float y1 = centroY + sin(angulo1) * radioInterno;
    
    // Longitud de línea basada en uso de apps
    float longitud1 = map(rank[i], 0, maxRank, 20, 200);
    
    // Efecto espiral
    float factorEspiral = 0.1;
    float anguloFinal1 = angulo1 + factorEspiral;
    float x2 = centroX + cos(anguloFinal1) * (radioInterno + longitud1);
    float y2 = centroY + sin(anguloFinal1) * (radioInterno + longitud1);
    
    // Dibujar línea de uso de apps
    stroke(100, 200, 255, 180);
    strokeWeight(1);
    line(x1, y1, x2, y2);
    
    // Punto al final de la línea
    fill(100, 200, 255);
    noStroke();
    ellipse(x2, y2, 5, 5);
    
    // SEGUNDA SERIE DE DATOS: Battery Drain
    // Usar otro ángulo desplazado para la segunda serie
    float angulo2 = angulo1 + (PI/nSamples); // Pequeño desplazamiento
    
    // Punto de inicio (círculo interior)
    float x3 = centroX + cos(angulo2) * radioInterno;
    float y3 = centroY + sin(angulo2) * radioInterno;
    
    // Longitud de línea basada en batería
    float longitud2 = map(naSales[i], 0, maxNaSales, 20, 200);
    
    // Efecto espiral para la segunda serie
    float anguloFinal2 = angulo2 + factorEspiral;
    float x4 = centroX + cos(anguloFinal2) * (radioInterno + longitud2);
    float y4 = centroY + sin(anguloFinal2) * (radioInterno + longitud2);
    
    // Dibujar línea de batería
    stroke(255, 100, 100, 180);
    strokeWeight(1);
    line(x3, y3, x4, y4);
    
    // Punto al final de la línea
    fill(255, 100, 100);
    noStroke();
    ellipse(x4, y4, 5, 5);
  }
}

// Para pausar/reanudar la rotación
void keyPressed() {
  if (key == ' ') {
    if (looping) noLoop();
    else loop();
  }
}
