# 📱 AQUASTASIS (Mobile Edition)
### **COP31 Antalya — Akdeniz Ekosistem Savunması (Mobil Sürüm)**
*GameUP Türkiye Oyun Hackathonu · COP31 Türkiye – Antalya Özel*

![Platform](https://img.shields.io/badge/Platform-Android_(APK)-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Engine](https://img.shields.io/badge/Engine-Godot_4.3+_Mobile-478cbf?style=for-the-badge&logo=godot-engine&logoColor=white)
![Audio](https://img.shields.io/badge/Audio-Prosed%C3%BCrel_Sentezleyici-ff69b4?style=for-the-badge)
![Languages](https://img.shields.io/badge/Dil-TR_%7C_EN_%7C_RU-e8a33d?style=for-the-badge)

---

## 🎯 Mobil Sürüm Genel Bakış

**Aquastasis Mobile**, ödüllü Akdeniz kriz simülasyonunun dokunmatik ekranlar ve mobil donanımlar için özel olarak optimize edilmiş versiyonudur:

* **Dokunmatik Arayüz (Touch-First UI):** Mobil cihazlar için yeniden tasarlanan genişletilmiş butonlar, dokunmatik hareketler (`pointing/emulate_touch_from_mouse`) ve sezgisel alt navigasyon çubuğu.
* **Prosedürel Ses Sentezleyici (`scripts/audio_synth.gd`):** Harici mp3/wav ses dosyalarına gerek kalmadan, `AudioStreamGenerator` ile gerçek zamanlı matematiksel dalgalardan sentezlenen derin okyanus uğultusu (48 Hz), radar pusu (750 Hz), DEFCON alarmları ve dinamik kalp atışı sesleri.
* **Mobil Render & Performans:** Godot 4 `mobile` renderer profili, ETC2/ASTC doku sıkıştırması, optimize edilmiş shader karmaşıklığı ve pil tasarrufu sağlayan 60 FPS kilitli simülasyon döngüsü.
* **Otomatik Yönlendirme:** Yatay (Landscape) geniş ekran deneyimi (`1280x720` ölçeklenebilir kanvas).

---

## 🚀 Kurulum ve Çalıştırma

### 1. Android Cihaza Doğrudan Yükleme (APK)
Klasör içinde hazır derlenmiş APK dosyası bulunmaktadır:
1. **`Aquastasis_Mobile.apk`** dosyasını Android telefonunuza veya tabletinize aktarın.
2. Cihazınızda dosyaya dokunarak yüklemeyi başlatın ("Bilinmeyen kaynaklardan yükleme" izni gerekebilir).
3. Yükleme tamamlandıktan sonra doğrudan açıp oynayabilirsiniz.

### 2. Godot Editörü ile Açma ve Geliştirme
1. **Godot 4.3+** editörünü açın.
2. **İçe Aktar (Import)** seçeneğiyle bu klasördeki `project.godot` dosyasını seçin.
3. Editör içinden doğrudan `F5` ile test edebilir veya `Proje -> Dışa Aktar (Export)` menüsünden yeni Android APK derlemeleri alabilirsiniz (`export_presets.cfg` hazır yapılandırılmıştır).

---

## 🎮 Kontroller (Mobil)

* **Dokunma (Bölge):** Akdeniz bölgesini seçer ve operasyon/durum kartını açar.
* **Dokunma (Baloncuklar):** Haritada beliren Mavi (Bilim) ve Sarı (Siyasi Destek) baloncuklarını toplayarak kaynak havuzunuza ekler.
* **Alt Operasyon Butonları:** Seçili bölgede anında **Acil Temizlik**, **Deniz Devriyesi (Kalkan)** ve **Halk Farkındalığı** başlatır.
* **Politika Ağacı Butonu:** 24 maddelik COP31 çevre yasaları ağacını açar.
