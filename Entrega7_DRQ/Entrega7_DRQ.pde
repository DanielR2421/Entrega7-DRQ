//Estas son las variables y arrays principales del codigo para cada categoria de la información que muestro de la base de datos
//Tuve ayuda de la IA para armar parte del codigo ya que había unas variables y arrays que habia que adaptara para que leyera los datos correctamente (esta fue el tiempo de duración de la pelicula porque se combinaron numeros con letras).
Table table;
int nSamples;
float[] rank; //Este es el array del ranking de IMDB de las peliculas van del 1 al 1000
String[] names;  // Este string es para almacenar nombres de películas
float[] rating; // Array del rating o clasificación que le dio el pubclico en general a las peliculas
float[] duration; //Array para la duración de las peliculas
float[] metaScore; //Array para la calificación que le dieron los criritcos a las peliculas

// Variables para la visualización de los circulos al igual que de las lineas que indican cual pelicuala es cual
float radioInterno = 120;
float rotacion = 0;
int muestraDatos = 250;  //cuantos datos se muestran inicialmente (lineas que salen del circulo principal).

// Centro del canvas
float centroX, centroY;

// Índice del círculo que esta sindo mostrado en la pantalla (0: Rank, 1: Rating, 2: Duration, 3: Metascore)
int circuloActivo = 0;

// Colores para cada círculo
color[] colores = {
  color(100, 200, 255), // Azul para rank
  color(255, 100, 100), // Rojo para rating
  color(100, 255, 100), // Verde para duration
  color(255, 255, 100)   // Amarillo para metascore
};

// Títulos para cada círculo de cada categoria que se muestra
String[] titulos = {"Rank", "Rating", "Duration", "Metascore"};

// Variables para mostrar información al hacer clic en cada linea con el punto que representa cada pelicula
String peliculaSeleccionada = "";
int tiempoMostrar = 0;

// Arrays para coordenadas de puntos de las peliculas el 1000 se utiliza ya que hay 1000 peliculas en la base de datso
float[][] puntosX = new float[4][1000];  // [círculo][punto]
float[][] puntosY = new float[4][1000];

void setup() {
  size(1200, 900);

  // Ubicación del centro del canvas
  centroX = width/2;
  centroY = height/2;

  // Cargar los datos
  table = loadTable("imdb_kaggle.csv", "header");
  nSamples = table.getRowCount();
  muestraDatos = min(nSamples, muestraDatos);

  // Inicializamción de todos los arrays funcionales de los datos que se visualizan
  rank = new float[nSamples];
  names = new String[nSamples];
  rating = new float[nSamples];
  duration = new float[nSamples];
  metaScore = new float[nSamples];

  // Asignación de los datos con condiciones normales (osea que son solo numeros sin letras)
  for (int i = 0; i < nSamples; i++) {
    rank[i] = table.getFloat(i, "rank");
    names[i] = table.getString(i, "name");
    rating[i] = table.getFloat(i, "rating");

    // Aqui se asume que la duración de cada pleicula se puede organizar como un String en el CSV ya que se combinan numeros con letras
    String durStr = table.getString(i, "duration");
    if (durStr != null && !durStr.trim().isEmpty()) {
      // Aquí se eliminan cualquier texto adicional que esten en la base de datos como "min" o "minutes"; Esto es lo que digo que me toco pedirle ayuda a la IA porque usando solo la base de la clase no supe como visualizar los datos que combinan numeros con letras
      durStr = durStr.replaceAll("[^0-9]", "");
      try {
        duration[i] = Float.parseFloat(durStr);
      }
      catch (Exception e) {
        duration[i] = 0; // Valor por defecto si hay error
        println("Error en duración para película " + names[i] + ": " + durStr);
      }
    } else {
      // Aca se intentan cargar los datos de la duración directamente como float si está disponible así, por lo mismo se combinan numeros con letras por lo que s fuera mas sencillo no se mostrarian los datos bien
      duration[i] = table.getFloat(i, "duration");
    }

    metaScore[i] = table.getFloat(i, "Metascore");
  }

  // Esta se es una verificación para ver si los datos de duración se muestran bien después de cargarlos
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

  // Esta es la velocidad de la rotación de los circulos con las graficas 
  rotacion += 0.002;

  // título principal de los datos mostrados 
  fill(255);
  textSize(40);  // Tamaño aumentado
  textAlign(CENTER, CENTER);
  text("Top 1000 IMDB Movies", width/2, 80);

  // Dibujo del círculo móvil
  if (circuloActivo == 0) {
    dibujarCirculo(rank, 1000, colores[0], titulos[0]);     // categoria de Rank
  } else if (circuloActivo == 1) {
    dibujarCirculo(rating, 10, colores[1], titulos[1]);     // categoria de Rating
  } else if (circuloActivo == 2) {
    dibujarCirculo(duration, 300, colores[2], titulos[2]);  // categoria de Duration
  } else if (circuloActivo == 3) {
    dibujarCirculo(metaScore, 100, colores[3], titulos[3]); // categoria de Metascore
  }

  // Indicador de círculo activo
  drawCircleIndicator();

  // Esto actualiza y muestra el titulo de la pelicula/ dato seleccionado por un tiempo de visualización 
  if (tiempoMostrar > 0) {
    tiempoMostrar--;
  }

  // Instrucciones para entender como funciona el la visualización de la base de datos en las esquinas inferiores 
  fill(200);
  textSize(18); 
  textAlign(LEFT);
  text("Haz clic para ver nombres", 30, height - 30);
  text("Espacio: Pausa", 30, height - 60);

  textAlign(RIGHT);
  text("Flechas ◄ ► cambiar datos", width - 30, height - 30);
  text("+/-: Ajustar cantidad", width - 30, height - 60);

  // ALineación correcta de los textos
  textAlign(CENTER, CENTER);
}

void drawCircleIndicator() {
  // Dibujo de pequeños indicadores en la parte inferior central que muestran qué círculo está activo o mejor dicho que se esta viendo
  float indicatorY = height - 80;
  float spacing = 30;
  float startX = width/2 - (spacing * 1.5);

  for (int i = 0; i < 4; i++) {
    float x = startX + (i * spacing);

    // Verificador del circulo con su color correspondiente osea rank = azul
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
  // Dibujo del círculo central
  fill(0);
  stroke(colorCirculo, 100);
  strokeWeight(2);
  ellipse(centroX, centroY, radioInterno * 2, radioInterno * 2);

  // Dibujo de los círculos exteriores
  noFill();
  stroke(colorCirculo, 40);
  strokeWeight(1);
  for (int i = 1; i <= 3; i++) {
    float radio = radioInterno + (i * 80);
    ellipse(centroX, centroY, radio * 2, radio * 2);
  }

  // Acta se muestra el título de la categoría dentro del círculo central
  fill(colorCirculo);
  textSize(28);  
  text(titulo, centroX, centroY - 15);  

  // Con este comando se muestra el nombre de película seleccionada debajo del título
  if (peliculaSeleccionada != "" && tiempoMostrar > 0) {
    fill(255, 255, 0);  // Amarillo para destacar - Cambiar luego
    textSize(16);  

    // con esto se limita el texto si es muy largo el titulo de la pelicula y no entra dentro del circulo central
    String nombreMostrar = peliculaSeleccionada;
    if (nombreMostrar.length() > 25) {
      nombreMostrar = nombreMostrar.substring(0, 22) + "...";
    }

    // Posicion del titulo de las pelicula seleccionada debajo del título de la categoría
    text(nombreMostrar, centroX, centroY + 15);
  }

  // Dibujo de los marcadores/ lineas de las peliculas que rotan con el circulos
  textSize(14);
  for (int i = 0; i < 12; i++) {
    float angulo = map(i, 0, 12, 0, TWO_PI) + rotacion;
    float x = centroX + cos(angulo) * (radioInterno * 0.8);
    float y = centroY + sin(angulo) * (radioInterno * 0.8);

    fill(colorCirculo);
    text(i+1, x, y);
  }

  // Por este codigo se muestran los datos datos en espiral en el ranking que le dio la gente
  float separacionAngular = TWO_PI / muestraDatos;

  for (int i = 0; i < muestraDatos; i++) {
    // Para calcular posiciones de los datos me ayudo la IA y tuve que volver a investigar conmo funcionaban la funciones de seno y coseno y como habia que modificarlas para poder mostrar o hacer que los datos que son visibles roten
    float angulo = (i * separacionAngular) + rotacion;
    float x1 = centroX + cos(angulo) * radioInterno;
    float y1 = centroY + sin(angulo) * radioInterno;

    float longitud = map(datos[i], 0, maximo, 20, 200);
    float anguloFinal = angulo + 0.1;  // Este es el factor que muestra las lineas de los marcadores de los datso con distintas longitudes como una espiral de acuerdo a su posición en el ranking que le dio el publico en general 
    float x2 = centroX + cos(anguloFinal) * (radioInterno + longitud);
    float y2 = centroY + sin(anguloFinal) * (radioInterno + longitud);

    // Con este condigo se coordenadas cuando se haga un clic en un marcador de un dato
    puntosX[circuloActivo][i] = x2;
    puntosY[circuloActivo][i] = y2;

    // Dibujo de las lineas de los maracores 
    stroke(colorCirculo, 180);
    strokeWeight(1);
    line(x1, y1, x2, y2);

    // Dibujo de los end points seleccionables de las lineas de los marcadores
    if (peliculaSeleccionada.equals(names[i]) && tiempoMostrar > 0) {
      fill(255);  // Punto/ marcador seleccionado
      ellipse(x2, y2, 8, 8);
    } else {
      fill(colorCirculo);
      ellipse(x2, y2, 5, 5);
    }

    // POr esta parte del codigo se muestra inicialmente un marcador cada 25 puntos o valores de acuerdo con la base de datos y se aumenta de la can
    if (i % 25 == 0) {
      fill(255);
      textSize(12);

      // Para este formato tuve que pedir mas ayuda de la IA para poder mostrar los datos de duración sin problema por la combinación de letras con numeros
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
  // con este evento del codigo se verifica si se hizo clic en algún punto del círculo activo (los end points de los marcadores)
  for (int i = 0; i < muestraDatos; i++) {
    if (dist(mouseX, mouseY, puntosX[circuloActivo][i], puntosY[circuloActivo][i]) < 10) {
      peliculaSeleccionada = names[i];
      tiempoMostrar = 180;  // ~6 segundos a 30 FPS; esto me lo ayudo a cuadrar la IA para que no haya tanto problema con la visualización de los datos al ser tantos
      return;
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    // el evento de la tecla de espacio se usa para pausar y reanudar la animación de la rotación del circulo con los datos
    if (looping) noLoop();
    else loop();
  } else if (key == '+' || key == '=') {
    // Evento de la tecla "+" para aumentar cantidad de datos visibles en el circulo
    muestraDatos = min(nSamples, muestraDatos + 50);
  } else if (key == '-' || key == '_') {
    // Evento de la tecla "-" para reducir cantidad de datos visibles en el circulo
    muestraDatos = max(50, muestraDatos - 50);
  } else if (keyCode == LEFT) {
    // Uso del evento de la flecha izquierda para mostrar el círculo con los datos anteriores
    circuloActivo = (circuloActivo - 1 + 4) % 4;
    peliculaSeleccionada = "";  // Cambio de selección al cambiar de círculo
  } else if (keyCode == RIGHT) {
    // Uso del evento de la flecha derecha para mostrar el círculo con los datos siguientes
    circuloActivo = (circuloActivo + 1) % 4;
    peliculaSeleccionada = "";  // Cambio de selección al cambiar de círculo
  }
}
