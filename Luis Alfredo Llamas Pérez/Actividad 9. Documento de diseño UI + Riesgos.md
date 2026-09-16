**Luis Alfredo Llamas Pérez  5:G**

## **1\. Concepto de UI (HUD, Canales de Información y Feedback)**

El diseño visual busca una interfaz minimalista. La UI 2D limpia contrasta con la distorsión progresiva del mundo 3D durante las crisis de TOC.

* **HUD:**  
    
  * **Sin barras fijas en pantalla:** Se evita el HUD tradicional  donde siempre están presentes las barras para maximizar la inmersión, apareciendo solo en momentos claves como cuando estás a punto de morir o aumentaste un indicador con un  item.  
  * **Canal Visual):**

    * ***Estado normal:*** Contornos limpios, minimalista.  
        
    * ***Aumento de Ansiedad:*** Aberración cromática, grano de película.  
        
  * **Canal Auditivo:**

    * ***Respiración y Latidos:*** Incremento del ritmo de la respiración del personaje y latidos, conforme la crisis o el monstruo se acerca.  
        
    * ***Audio  ambiental:*** El sonido del entorno puede ir desde sonido ambiental(risas, pájaros) tradicional a música melancólica o feliz.  
* **HUD en Diálogos :**  
    
  * **Caja de Texto:** Cuadro inferior con diálogo tipo novela visual.  
      
    

## **2\. Loop Principal de Interacción**

1. **Transición a Novela Visual (2D):** Empieza con la apariencia con 2D que muestra el desenlace o inicio de una crisis, siendo el inicio del loop.

   

2. **Detonante de Ansiedad (TOC):** Ocurre un evento trigger (ej. un detonante).  
     
3. **Nivel 3D:** El jugador ingresa el entorno 3D interactuando con objetos clave y huyendo de enemigos a la vez que corre.  
     
4. **Decisión:**La persona que juega decide si toma escitalopram para intentar resistir a la crisis.

      5\. **Fin del nivel:** La persona que juega llega al fin del nivel 3D y es tomada de nuevo al inicio del loop con una escena.

## **3\. Dinámicas Asociadas y Regulación por la UI**

| Dinámica | Manifestación en la UI | Regulación y Control de la UI |
| :---: | :---: | :---: |
| **Gestión del Escitalopram:** Decidir si gastar el ítem en ganar milisegundos o ahorrarlo para comprar herramientas. | Contador de Escitalopram disponible y tienda/menú de herramientas en pantalla. | La UI muestra el costo en tiempo real, forzando al jugador a sopesar el riesgo de gastar recursos ahora o quedar vulnerable después. |
| **Punto de No Retorno (TOC Toma el Control):** Si te quedas sin Escitalopram y sin herramientas en etapas finales, la dificultad se vuelve abrumadora. | Audio especial para estas situaciones, donde se interprete que estás en una situación difícil. | La UI comunica visualmente la inevitabilidad del colapso, empujando al jugador hacia el desenlace narrativo pesimista. |
| **Navegación Intuitiva: Saber hacia dónde dirigirse casi al instante durante la persecución/exploración.**  | Señales de minimalistas en pantalla.  | La UI guía al jugador sin romper la inmersión, permitiendo tomar decisiones rápidas de movimiento durante el estado de alerta.  |

## 

## 

## 

## 

## 

## **4\. Principal Riesgo del Diseño y Validación con Prototipo**

* **Principal Riesgo Identificado:** **Riesgo de Experiencia de Usuario:**

  * ***El problema:*** Romper de forma abrupta la acción en 3D para entrar a la Novela Visual 2D puede sentirse "frustrante".  
  *   
* **Plan de Validación mediante Prototipo (Mecánica Mínima Viable):**  
  

  * **Objetivo:** Probar el "sentimiento de transición" en las primeras 2 semanas de desarrollo.  
  *   
  * **Paso 1 (Greybox):** Crear una escena 3D básica con un bloque (cubo) caminando en un pasillo.  
  *   
  * **Paso 2 (Trigger):** Al tocar un disparador, activar durante 3 segundos la aberración de colores y congelar el movimiento del jugador.  
  *   
  * **Paso 3 (Pop-up 2D):** Desplegar una imagen 2D provisional de prueba.  
      
  * **Criterio de Éxito:** Si el cambio de cámara y el frenado del movimiento se sienten como un "ataque de pánico controlado" y no como un error de programación, la mecánica pasa a producción.  
    

## **5\. Trade-off Explícito**

* **Decisión:** Sacrificar el realismo técnico en 3D y cinemáticas animadas en favor del arte 2D ilustrado.  
    
* **Lo que perdemos:** Gráficos fotorrealistas, animaciones faciales 3D (lip-sync), cinemáticas complejas en tiempo real.  
    
* **Lo que ganamos:**  
  

  * Garantía de entregar buenas escenas en la entrega final sin sobrecargar de trabajo de modelado/animación.  
      
  * Preservación del "alma artística" del juego mediante ilustraciones 2D.  
      
  * Rendimiento bueno garantizado.  
    

## **6\. Justificación de Decisiones**

1. **Uso de Efectos de Pantalla:** En lugar de crear animaciones 3D complejas para comunicar la crisis del personaje, la UI asume la carga expresiva. Es barato en cuanto a costos de tiempo y esfuerzo implementar en Unity.  
     
2. **Sistema de Audio Sordo (Text-bips \+ Latidos):** Evita el costo del doblaje de voz, utilizando el diseño sonoro ambiental como la principal fuente de feedback.  
 


