// 1. Geçiş Tetikleme Kontrolü
if (change == true && fade_state == 0) { 
    fade_state = 1;
    obj_textbox.ready = false;
}

// 2. Durum Makinesi (Cutscene Akışı)
switch (fade_state) {
    
    // EKRAN KARARMA AŞAMASI
    case 1:
        fade_alpha += fade_speed;
        
        if (fade_alpha >= 1) {
            fade_alpha = 1;
            image_index += 1; // Sonraki sahne görseline geç
            fade_state = 2;   // Ekranı açma aşamasına geç
        }
    break;

    // EKRAN AÇILMA AŞAMASI
    case 2:
        fade_alpha -= fade_speed;
        
        if (fade_alpha <= 0) {
            fade_alpha = 0;
            fade_state = 0;
            change = false;
            obj_textbox.ready = true; // Textbox tekrar hazır
            
            // --- MÜZİK KONTROLÜ ---
            // Cutscene sahneleri bittiğinde (yani image_index son kareye ulaştığında) müziği başlat
            if (image_index >= image_number - 1) {
                scr_play_music(msc_ambient, true);
            }
        }
    break;
}