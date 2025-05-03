Table table;
int nSamples;
float[] rank;
String[] names;  // Para almacenar nombres de películas
float[] rating;
float[] duration;
float[] metaScore;

// Variables para la visualización
float radioInterno = 120;  
float rotacion = 0;
int muestraDatos = 250;  

// Centro del canvas
float centroX, centroY;

// Índice del círculo actualmente mostrado (0: Rank, 1: Rating, 2: Duration, 3: Metascore)
int circuloActivo = 0;

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
int tiempoMostrar = 0;

// Arrays para coordenadas de puntos
float[][] puntosX = new float[4][1000];  // [círculo][punto]
float[][] puntosY = new float[4][1000];

void setup() {
  size(1200, 900);  // Canvas ampliado
  
  // Calcular el centro del canvas
  centroX = width/2;
  centroY = height/2;
  
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
    
    // Asegurar que los datos de duración se cargan correctamente
    // Asumimos que la duración podría estar como String en el CSV
    String durStr = table.getString(i, "duration");
    if (durStr != null && !durStr.trim().isEmpty()) {
      // Eliminar cualquier texto adicional (como "min" o "minutes")
      durStr = durStr.replaceAll("[^0-9]", "");
      try {
        duration[i] = Float.parseFloat(durStr);
      } catch (Exception e) {
        duration[i] = 0; // Valor por defecto si hay error
        println("Error en duración para película " + names[i] + ": " + durStr);
      }
    } else {
      // Intentar cargar directamente como float si está disponible así
      duration[i] = table.getFloat(i, "duration");
    }
    
    metaScore[i] = table.getFloat(i, "Metascore");
  }
  
  // Verificar los datos de duración después de cargarlos
  println("Verificando datos de duración:");
  for (int i = 0; i < min(10, nSamples); i++) {
    println("Película " + names[i] + ": " + duration[i] + " minutos");
  }
  
  textAlign(CENTER, CENTER);
  frameRate(30);
  
  println("Canvas size: " + width + "x" + height);
  println("Centro del canvas: " + centroX + ", " + centroY);
}

void draw() {
  background(0);
  
  // Actualizar rotación
  rotacion += 0.002;
  
  // Dibujar título principal
  fill(255);
  textSize(40);  // Tamaño aumentado
  textAlign(CENTER, CENTER);
  text("IMDB Movies Visualization", width/2, 80);
  
  // Dibujar el círculo activo
  if (circuloActivo == 0) {
    dibujarCirculo(rank, 1000, colores[0], titulos[0]);     // Rank
  } else if (circuloActivo == 1) {
    dibujarCirculo(rating, 10, colores[1], titulos[1]);     // Rating
  } else if (circuloActivo == 2) {
    dibujarCirculo(duration, 300, colores[2], titulos[2]);  // Duration
  } else if (circuloActivo == 3) {
    dibujarCirculo(metaScore, 100, colores[3], titulos[3]); // Metascore
  }
  
  // Indicador de círculo activo
  drawCircleIndicator();
  
  // Actualizar tiempo de visualización del nombre
  if (tiempoMostrar > 0) {
    tiempoMostrar--;
  }
  
  // Instrucciones en las esquinas inferiores con tamaño agrandado
  fill(200);
  textSize(18);  // Tamaño aumentado
  textAlign(LEFT);
  text("Haz clic para ver nombres", 30, height - 30);
  text("Espacio: Pausa", 30, height - 60);
  
  textAlign(RIGHT);
  text("Flechas ◄ ► cambiar datos", width - 30, height - 30);
  text("+/-: Ajustar cantidad", width - 30, height - 60);
  
  // Restablecer alineación
  textAlign(CENTER, CENTER);
}

void drawCircleIndicator() {
  // Dibujar pequeños indicadores en la parte inferior central para mostrar qué círculo está activo
  float indicatorY = height - 80;
  float spacing = 30;
  float startX = width/2 - (spacing * 1.5);
  
  for (int i = 0; i < 4; i++) {
    float x = startX + (i * spacing);
    
    // Dibujar círculo con el color correspondiente
    if (i == circuloActivo) {
      // Círculo activo: más grande y lleno
      fill(colores[i]);
      ellipse(x, indicatorY, 20, 20);
    } else {
      // Círculos inactivos: más pequeños y huecos
      noFill();
      stroke(colores[i]);
      strokeWeight(2);
      ellipse(x, indicatorY, 15, 15);
    }
  }
}

void dibujarCirculo(float[] datos, float maximo, color colorCirculo, String titulo) {
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
    float radio = radioInterno + (i * 80);
    ellipse(centroX, centroY, radio * 2, radio * 2);
  }
  
  // Mostrar el título de la categoría dentro del círculo central
  fill(colorCirculo);
  textSize(28);  // Tamaño aumentado para el título de la categoría
  text(titulo, centroX, centroY - 15);  // Subir el título un poco
  
  // Mostrar nombre de película seleccionada debajo del título
  if (peliculaSeleccionada != "" && tiempoMostrar > 0) {
    fill(255, 255, 0);  // Amarillo para destacar
    textSize(16);  // Tamaño adecuado para el título de la película
    
    // Limitar el texto si es muy largo
    String nombreMostrar = peliculaSeleccionada;
    if (nombreMostrar.length() > 25) {
      nombreMostrar = nombreMostrar.substring(0, 22) + "...";
    }
    
    // Posicionar debajo del título de la categoría
    text(nombreMostrar, centroX, centroY + 15);
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
    
    float longitud = map(datos[i], 0, maximo, 20, 200);
    float anguloFinal = angulo + 0.1;  // Factor espiral
    float x2 = centroX + cos(anguloFinal) * (radioInterno + longitud);
    float y2 = centroY + sin(anguloFinal) * (radioInterno + longitud);
    
    // Guardar coordenadas para detección de clic
    puntosX[circuloActivo][i] = x2;
    puntosY[circuloActivo][i] = y2;
    
    // Dibujar línea
    stroke(colorCirculo, 180);
    strokeWeight(1);
    line(x1, y1, x2, y2);
    
    // Dibujar punto
    if (peliculaSeleccionada.equals(names[i]) && tiempoMostrar > 0) {
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
      
      // Formato especial para duración
      if (circuloActivo == 2) {
        int minutos = int(datos[i]);
        text(minutos + " min", x2 + cos(anguloFinal) * 12, y2 + sin(anguloFinal) * 12);
      } else {
        text(nf(datos[i], 0, 1), x2 + cos(anguloFinal) * 12, y2 + sin(anguloFinal) * 12);
      }
    }
  }
}

void mousePressed() {
  // Verificar si se hizo clic en algún punto del círculo activo
  for (int i = 0; i < muestraDatos; i++) {
    if (dist(mouseX, mouseY, puntosX[circuloActivo][i], puntosY[circuloActivo][i]) < 10) {
      peliculaSeleccionada = names[i];
      tiempoMostrar = 180;  // ~6 segundos a 30 FPS
      return;
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    // Espacio: pausa/reanuda la animación
    if (looping) noLoop();
    else loop();
  } else if (key == '+' || key == '=') {
    // Aumentar cantidad de datos
    muestraDatos = min(nSamples, muestraDatos + 50);
  } else if (key == '-' || key == '_') {
    // Reducir cantidad de datos
    muestraDatos = max(50, muestraDatos - 50);
  } else if (keyCode == LEFT) {
    // Flecha izquierda: círculo anterior
    circuloActivo = (circuloActivo - 1 + 4) % 4;
    peliculaSeleccionada = "";  // Limpiar selección al cambiar de círculo
  } else if (keyCode == RIGHT) {
    // Flecha derecha: círculo siguiente
    circuloActivo = (circuloActivo + 1) % 4;
    peliculaSeleccionada = "";  // Limpiar selección al cambiar de círculo
  }
}
