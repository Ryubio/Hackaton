# 📱 AQUASTASIS (Mobile Edition)
### **Küresel Okyanus Ekosistem ve Kriz Simülasyonu (Mobil Sürüm)**

![Platform](https://img.shields.io/badge/Platform-Android_(APK)-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Engine](https://img.shields.io/badge/Engine-Godot_4.3+_Mobile-478cbf?style=for-the-badge&logo=godot-engine&logoColor=white)
![Audio](https://img.shields.io/badge/Audio-Prosed%C3%BCrel_Sentezleyici-ff69b4?style=for-the-badge)
![Languages](https://img.shields.io/badge/Dil-TR_%7C_EN_%7C_RU-e8a33d?style=for-the-badge)

---

## 🎯 Mobil Sürüm Genel Bakış

**Aquastasis Mobile**, 12 küresel okyanus ve deniz bölgesini kapsayan gerçek zamanlı ekosistem kriz simülasyonunun dokunmatik ekranlar ve mobil donanımlar için özel olarak optimize edilmiş versiyonudur:

* **Küresel Dünya Haritası (360° Sonsuz Yatay Geçiş):** Kamu malı Natural Earth 1:110m kıyı verilerinden türetilmiş kesintisiz dünya haritası, okyanus akıntıları ve stratejik deniz ticareti rotaları.
* **Seçilebilir Karargah (HQ):** Her seferin başında karargah bölgenizi dünya okyanuslarından dilediğiniz noktada kurun.
* **Dokunmatik Arayüz (Touch-First UI):** Mobil cihazlar için yeniden tasarlanan genişletilmiş butonlar, sürükle/yakınlaştır harita kontrolleri (`pointing/emulate_touch_from_mouse`) ve sezgisel alt navigasyon çubuğu.
* **Prosedürel Ses Sentezleyici (`scripts/audio_synth.gd`):** Harici mp3/wav ses dosyalarına gerek kalmadan, `AudioStreamGenerator` ile gerçek zamanlı sentezlenen derin okyanus uğultusu, sonar pingi, DEFCON alarmları ve dinamik kalp atışı sesleri.
* **Mobil Render & Performans:** Godot 4 `mobile` renderer profili, optimize edilmiş shader karmaşıklığı ve pil tasarrufu sağlayan 60 FPS kilitli simülasyon döngüsü.

---

## 🚀 Kurulum ve Çalıştırma

### 1. Android Cihaza Doğrudan Yükleme (APK)
1. **`Aquastasis_Mobile.apk`** dosyasını Android telefonunuza veya tabletinize aktarın.
2. Cihazınızda dosyaya dokunarak yüklemeyi başlatın ("Bilinmeyen kaynaklardan yükleme" izni gerekebilir).
3. Yükleme tamamlandıktan sonra doğrudan açıp oynayabilirsiniz.

### 2. Godot Editörü ile Açma ve Geliştirme
1. **Godot 4.3+** editörünü açın.
2. **İçe Aktar (Import)** seçeneğiyle bu klasördeki `project.godot` dosyasını seçin.
3. Editör içinden doğrudan `F5` ile test edebilir veya `Proje -> Dışa Aktar (Export)` menüsünden Android APK derlemesi alabilirsiniz.

---

## 🎮 Kontroller (Mobil)

* **Dokunma (Bölge):** Okyanus bölgesini seçer ve operasyon/durum kartını açar.
* **Kaydırma & Çimdik (Pan & Zoom):** Haritada 360° doğu-batı kesintisiz kaydırma ve yakınlaştırma yapar.
* **Dokunma (Baloncuklar):** Haritada beliren Bilim ve Siyasi Destek baloncuklarını toplar.
* **Alt Operasyon Butonları:** Seçili bölgede anında **Acil Temizlik**, **Deniz Devriyesi (Kalkan)** ve **Halk Farkındalığı** başlatır.
* **Politika Ağacı Butonu:** 24 maddelik Küresel Okyanus çevre yasaları ağacını açar.
