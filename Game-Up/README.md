# 🌊 AQUASTASIS (Pulse of the Mediterranean)
### **COP31 Antalya — Akdeniz Ekosistem Savunması ("Tersine Salgın" Simülasyonu)**
*GameUP Türkiye Oyun Hackathonu · COP31 Türkiye – Antalya Özel*

![Godot 4](https://img.shields.io/badge/Engine-Godot_4.3+-478cbf?style=for-the-badge&logo=godot-engine&logoColor=white)
![Platforms](https://img.shields.io/badge/Platform-Windows_(PC)_%7C_Android_(Mobile)-green?style=for-the-badge)
![Zero Asset](https://img.shields.io/badge/Mimari-%25100_Prosed%C3%BCrel_(S%C4%B1f%C4%B1r_Harici_Varl%C4%B1k)-19e6c1?style=for-the-badge)
![Languages](https://img.shields.io/badge/Dil-TR_%7C_EN_%7C_RU-e8a33d?style=for-the-badge)

---

## 📁 Proje Yapısı (Repository Structure)

Bu depo, GameUP Türkiye Hackathonu için geliştirilen projenin hem **Masaüstü (PC)** hem de **Mobil (Android)** sürümlerini barındıran tam teşekküllü monorepo yapısıdır:

```
Game-Up/
├── 🖥️ Aquastasis-Pc/          # Masaüstü (PC) Godot 4 Projesi
│   ├── project.godot          # PC Godot Proje Yapılandırması (1920x1080 Forward+)
│   ├── oyunu_baslat.bat       # Windows tek tıkla başlatıcı
│   ├── scripts/               # PC simülasyon, HUD, ağaç ve mantık kodları
│   ├── shaders/               # Akdeniz deniz, akıntı ve grid GLSL shader'ları
│   ├── docs/                  # Mimari kontratı ve tasarım belgeleri
│   └── README.md              # PC sürümü detaylı rehberi
│
└── 📱 Aquastasis-Mobile/      # Mobil (Android) Godot 4 Projesi
    ├── project.godot          # Mobil Godot Proje Yapılandırması (1280x720 Mobile Renderer)
    ├── export_presets.cfg     # Android dışa aktarım profili
    ├── Aquastasis_Mobile.apk  # Doğrudan yüklenebilir hazır Android paketi
    ├── assets/                # Mobil simge, emblem ve açılış görselleri
    ├── scripts/               # Dokunmatik UI, AudioSynth ve mobil mantık
    ├── shaders/               # Mobil GPU optimize shader'lar
    └── README.md              # Mobil sürüm kurulum ve APK rehberi
```

---

## 🎯 Proje Özeti ve İklim Konusuyla İlişkisi

**Pulse of the Mediterranean (Aquastasis)**, oyuncunun **COP31 Antalya Deniz Koalisyonu** lideri olarak Akdeniz havzasını 2026–2046 yılları arasında ekolojik çöküşten kurtarmaya çalıştığı, gerçek zamanlı bir ekolojik strateji ve kriz simülasyonudur.

* **Odak Alan:** **Okyanuslar ve Denizler (COP31 Öncelikli Teması)**.
* **Oyuncu Rolü:** Antalya Körfezi merkezli COP31 Koalisyonu'nu yöneterek Bütçe, Siyasi Destek ve Bilim kaynaklarını dengeler; Akdeniz'in 8 kritik bölgesinde acil temizlik yapar (`[Q]`), deniz koruma devriyeleri kurar (`[W]`), halk farkındalık kampanyaları yürütür (`[E]`) ve 24 düğümlü Politika Ağacı (`[T]`) ile kalıcı reformları hayata geçirir.
* **İklim Kriziyle İlişkisi:** Deniz suyu ısınması (`+1.5°C -> +4.0°C`), plastik kirliliği, asitlenme, aşırı avlanma, istilacı tür göçleri, mercan ağarması ve *Posidonia oceanica* deniz çayırlarının kaybı gibi gerçek iklim dinamiklerini simüle eder.

---

## 🚀 Hızlı Başlatma Rehberi

### 🖥️ PC Sürümünü Oynamak İçin:
* [Aquastasis-Pc](Aquastasis-Pc/) klasörüne girin.
* Windows üzerinde doğrudan **`oyunu_baslat.bat`** betiğini çalıştırın veya Godot 4 editöründen `Aquastasis-Pc/project.godot` dosyasını açıp `F5` tuşuna basın.

### 📱 Mobil Sürümü Oynamak İçin:
* [Aquastasis-Mobile](Aquastasis-Mobile/) klasörüne girin.
* Klasör içindeki **`Aquastasis_Mobile.apk`** dosyasını Android telefonunuza aktarıp yükleyin veya Godot 4 ile `Aquastasis-Mobile/project.godot` projesini test edin.

---

## 🛠️ Teknik Mimari (%100 Prosedürel Sıfır Harici Varlık)

* **Prosedürel 3B Akdeniz Haritası:** 8 deniz bölgesinin çokgenleri `Geometry2D.triangulate_polygon()` ile gerçek zamanlı 3B mesh'e dönüştürülür.
* **Özel GLSL Shader'lar:** Kirlilik seviyesine göre su rengi, dalga genliği ve kriz yayılım şok dalgaları GPU üzerinde hesaplanır.
* **Prosedürel Ses Sentezleyici:** `AudioStreamGenerator` ile harici ses dosyası olmaksızın 48 Hz okyanus uğultusu, 750 Hz sonar pingleri ve DEFCON alarm sesleri matematiksel dalgalarla üretilir.
* **3 Dil Canlı Yerelleştirme:** Türkçe, İngilizce ve Rusça tam dil desteği.
* **Otomatik Doğrulama ve Monte Carlo Testleri:** Headless modda 1000 tick simülasyon ve tip güvenliği test süiti.
