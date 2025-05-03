Table table;
int nSamples;
float[] rank;
String[] names;  // Para almacenar nombres de películas
float[] rating;
float[] duration;
float[] metaScore;

// Variables para la visualización
float radioInterno = 100;  
float rotacion = 0;
int muestraDatos = 250;  

// Posiciones de los cuatro círculos - Ajustadas para asegurar visibilidad
float[][] centros = {
  {width/4, height/4},      // Círculo 1 (Rank)
  {3*width/4, height/4},    // Círculo 2 (Rating) 
  {width/4, 3*height/4},    // Círculo 3 (Duration)
  {3*width/4, 3*height/4}   // Círculo 4 (Metascore)
};

// Colores para cada círculo
color[] colores = {
  color(100, 200, 255),  // Azul para rank
  color(255, 100, 100),  // Rojo para rating
  color(100, 255, 100),  // Verde para duration
  color(255, 255, 100)   // Amarillo para metascore
};

// Títulos para cada círculo
String[] titulos = {"Rank", "Rating", "Duration", "Metascore"};

// Variables para mostrar información al hacer clic
String peliculaSeleccionada = "";
int circuloSeleccionado = -1;
int tiempoMostrar = 0;

// Arrays para coordenadas de puntos
float[][] puntosX = new float[4][1000];  // [círculo][punto]
float[][] puntosY = new float[4][1000];

void setup() {
  size(1800, 1800);  // Canvas ampliado
  
  // Recalcular posiciones de círculos después de establecer el tamaño
  centros[0][0] = width/4;    centros[0][1] = height/4;
  centros[1][0] = 3*width/4;  centros[1][1] = height/4;
  centros[2][0] = width/4;    centros[2][1] = 3*height/4;
  centros[3][0] = 3*width/4;  centros[3][1] = 3*height/4;
  
  // Cargar los datos
  table = loadTable("imdb_kaggle.csv", "header");
  nSamples = table.getRowCount();
  muestraDatos = min(nSamples, muestraDatos);
  
  // Inicializamos los arrays
  rank = new float[nSamples];
  names = new String[nSamples];
  rating = new float[nSamples];
  duration = new float[nSamples];
  metaScore = new float[nSamples];
  
  // Asignamos los datos
  for (int i = 0; i < nSamples; i++) {
    rank[i] = table.getFloat(i, "rank");
    names[i] = table.getString(i, "name");
    rating[i] = table.getFloat(i, "rating");
    duration[i] = table.getFloat(i, "duration");
    metaScore[i] = table.getFloat(i, "Metascore");
  }
  
  textAlign(CENTER, CENTER);
  frameRate(30);
  
  println("Canvas size: " + width + "x" + height);
  println("Círculo 1 (Rank): " + centros[0][0] + ", " + centros[0][1]);
  println("Círculo 2 (Rating): " + centros[1][0] + ", " + centros[1][1]);
  println("Círculo 3 (Duration): " + centros[2][0] + ", " + centros[2][1]);
  println("Círculo 4 (Metascore): " + centros[3][0] + ", " + centros[3][1]);
}

void draw() {
  background(0);
  
  // Actualizar rotación
  rotacion += 0.002;
  
  // Dibujar título principal
  fill(255);
  textSize(36);
  text("IMDB Movies Visualization", width/2, 80);
  text("Haz clic para ver nombres | Espacio: Pausa | +/-: Ajustar datos", width/2, 120);
  
  // Dibujar los cuatro círculos con sus datos
  dibujarCirculo(0, rank, 1000);     // Círculo 1: Rank (valor máximo aproximado)
  dibujarCirculo(1, rating, 10);     // Círculo 2: Rating (escala 0-10)
  dibujarCirculo(2, duration, 300);  // Círculo 3: Duration (minutos)
  dibujarCirculo(3, metaScore, 100); // Círculo 4: Metascore (escala 0-100)
  
  // Actualizar tiempo de visualización del nombre
  if (tiempoMostrar > 0) {
    tiempoMostrar--;
  }
  
  // Mostrar una etiqueta clara para cada cuadrante
  for (int i = 0; i < 4; i++) {
    fill(colores[i]);
    textSize(28);
    text(titulos[i], centros[i][0], centros[i][1] - radioInterno - 30);
  }
}

void dibujarCirculo(int indiceCirculo, float[] datos, float maximo) {
  // Posición y estilo del círculo
  float centroX = centros[indiceCirculo][0];
  float centroY = centros[indiceCirculo][1];
  color colorCirculo = colores[indiceCirculo];
  
  // Dibujar círculo central
  fill(0);
  stroke(colorCirculo, 100);
  strokeWeight(2);
  ellipse(centroX, centroY, radioInterno * 2, radioInterno * 2);
  
  // Dibujar círculos concéntricos
  noFill();
  stroke(colorCirculo, 40);
  strokeWeight(1);
  for (int i = 1; i <= 3; i++) {
    float radio = radioInterno + (i * 90);
    ellipse(centroX, centroY, radio * 2, radio * 2);
  }
  
  // Dibujar título o nombre de película
  if (circuloSeleccionado == indiceCirculo && peliculaSeleccionada != "" && tiempoMostrar > 0) {
    // Mostrar título y nombre de película
    fill(255);
    textSize(16);
    text(titulos[indiceCirculo], centroX, centroY - 20);
    
    fill(255, 255, 0);  // Amarillo para destacar
    String nombreMostrar = peliculaSeleccionada.length() > 30 ? 
                          peliculaSeleccionada.substring(0, 27) + "..." : 
                          peliculaSeleccionada;
    text(nombreMostrar, centroX, centroY + 10);
  } else {
    // Solo mostrar título
    fill(255);
    textSize(20);
    text(titulos[indiceCirculo], centroX, centroY);
  }
  
  // Dibujar marcadores
  textSize(14);
  for (int i = 0; i < 12; i++) {
    float angulo = map(i, 0, 12, 0, TWO_PI) + rotacion;
    float x = centroX + cos(angulo) * (radioInterno * 0.8);
    float y = centroY + sin(angulo) * (radioInterno * 0.8);
    
    fill(colorCirculo);
    text(i+1, x, y);
  }
  
  // Dibujar datos en espiral
  float separacionAngular = TWO_PI / muestraDatos;
  
  for (int i = 0; i < muestraDatos; i++) {
    // Calcular posiciones
    float angulo = (i * separacionAngular) + rotacion;
    float x1 = centroX + cos(angulo) * radioInterno;
    float y1 = centroY + sin(angulo) * radioInterno;
    
    float longitud = map(datos[i], 0, maximo, 30, 270);
    float anguloFinal = angulo + 0.1;  // Factor espiral
    float x2 = centroX + cos(anguloFinal) * (radioInterno + longitud);
    float y2 = centroY + sin(anguloFinal) * (radioInterno + longitud);
    
    // Guardar coordenadas para detección de clic
    puntosX[indiceCirculo][i] = x2;
    puntosY[indiceCirculo][i] = y2;
    
    // Dibujar línea
    stroke(colorCirculo, 180);
    strokeWeight(1);
    line(x1, y1, x2, y2);
    
    // Dibujar punto
    if (circuloSeleccionado == indiceCirculo && peliculaSeleccionada.equals(names[i]) && tiempoMostrar > 0) {
      fill(255);  // Punto destacado
      ellipse(x2, y2, 8, 8);
    } else {
      fill(colorCirculo);
      ellipse(x2, y2, 5, 5);
    }
    
    // Mostrar valor cada 25 puntos
    if (i % 25 == 0) {
      fill(255);
      textSize(12);
      text(nf(datos[i], 0, 1), x2 + cos(anguloFinal) * 12, y2 + sin(anguloFinal) * 12);
    }
  }
}

void mousePressed() {
  // Verificar si se hizo clic en algún punto
  for (int c = 0; c < 4; c++) {
    for (int i = 0; i < muestraDatos; i++) {
      if (dist(mouseX, mouseY, puntosX[c][i], puntosY[c][i]) < 10) {
        peliculaSeleccionada = names[i];
        circuloSeleccionado = c;
        tiempoMostrar = 180;  // ~6 segundos a 30 FPS
        return;
      }
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    if (looping) noLoop();
    else loop();
  }
  if (key == '+' || key == '=') {
    muestraDatos = min(nSamples, muestraDatos + 50);
  }
  if (key == '-' || key == '_') {
    muestraDatos = max(50, muestraDatos - 50);
  }
}
