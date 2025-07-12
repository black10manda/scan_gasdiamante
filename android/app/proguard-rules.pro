# Evita que Proguard elimine las clases de ML Kit necesarias
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# También evita errores con otras clases relacionadas al reconocimiento de texto
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.android.gms.vision.**