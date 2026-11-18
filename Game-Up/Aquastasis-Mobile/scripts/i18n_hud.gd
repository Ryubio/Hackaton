extends RefCounted
## String table (HUD additions, news ticker templates and ambient headlines, bubble labels. Owner: HUD module (en), localization (tr/ru)) merged by the I18n autoload; never read directly by game code.
## Format: key -> {"tr": ..., "en": ..., "ru": ...}. Keys are unique across all tables.

const STRINGS := {
	# --- HUD: net income per year beside each resource ---
	"hud.rate": {"tr": "{v}/yıl", "en": "{v}/yr", "ru": "{v}/год"},
	"hud.rate.tip": {"tr": "Harcamalardan önceki net yıllık gelir.", "en": "Net income per year, before spending.", "ru": "Чистый годовой доход до расходов."},
	"hud.rate.tip_negative": {
		"tr": "Gelir dengesi negatif: ölen bir okyanus koalisyon bütçesini tüketir. Tersine çevirmek için Deniz Sağlığını yükselt.",
		"en": "Income is negative: a dying ocean costs the coalition money. Restore Sea Health to turn it around.",
		"ru": "Доход отрицательный: умирающий океан истощает казну. Восстановите здоровье моря.",
	},
	"hud.toast.income_negative": {
		"tr": "Gelir dengesi negatife döndü! Kriz bütçeyi tüketiyor.",
		"en": "Income balance turned negative! The dying ocean is draining the budget.",
		"ru": "Баланс доходов стал отрицательным! Умирающий океан истощает бюджет.",
	},

	# --- HUD: live chart ---
	"hud.chart.title": {"tr": "CANLI EĞİLİM", "en": "LIVE TREND", "ru": "ЖИВОЙ ТРЕНД"},
	"hud.chart.health": {"tr": "Deniz Sağlığı", "en": "Sea Health", "ru": "Здоровье моря"},
	"hud.chart.crisis": {"tr": "Kriz Seviyesi", "en": "Crisis Level", "ru": "Уровень кризиса"},
	"hud.chart.goal": {"tr": "Hedef", "en": "Goal", "ru": "Цель"},

	# --- HUD: crisis resistances and evolution pressure ---
	"hud.resist.title": {"tr": "KRİZ DİRENÇLERİ", "en": "CRISIS RESISTANCES", "ru": "СОПРОТИВЛЕНИЯ КРИЗИСА"},
	"hud.resist.none": {"tr": "Henüz yok. Stratejini çeşitli tutarak böyle kalmasını sağla.", "en": "None yet. Keep your strategy varied to keep it that way.", "ru": "Пока нет. Разнообразьте стратегию, чтобы избежать мутаций."},
	"hud.resist.counter": {"tr": "Karşı politika: {list}", "en": "Countered by: {list}", "ru": "Нейтрализуется: {list}"},
	"hud.resist.counter_unknown": {"tr": "Politika Ağacı'ndaki uygun politikalarla önlenir.", "en": "Countered by matching policies in the Policy Tree.", "ru": "Нейтрализуется политиками в Древе."},
	"hud.resist.more": {"tr": "Ayrıca aktif: {n}", "en": "Also active: {n}", "ru": "Также активно: {n}"},
	"hud.pressure.warn": {"tr": "Kriz direnç geliştiriyor: {branch}", "en": "Crisis adapting to: {branch}", "ru": "Кризис вырабатывает стойкость: {branch}"},
	"hud.pressure.hint": {"tr": "Hamlelerini çeşitlendir, aksi takdirde kriz direnç geliştirecek.", "en": "Diversify your moves or it evolves a resistance.", "ru": "Разнообразьте действия, иначе кризис разовьет сопротивление."},
	"hud.branch.protect": {"tr": "Koruma", "en": "Protection", "ru": "Охрана"},
	"hud.branch.source": {"tr": "Kaynak Kesme", "en": "Source Cutting", "ru": "Устранение источников"},
	"hud.branch.science": {"tr": "Bilim ve Toplum", "en": "Science & Public", "ru": "Наука и общество"},
	"hud.branch.economy": {"tr": "Ekonomi ve Diplomasi", "en": "Economy & Diplomacy", "ru": "Экономика и дипломатия"},

	# --- HUD: policy tree button and key hints ---
	"hud.tree.button": {"tr": "POLİTİKA AĞACI", "en": "POLICY TREE", "ru": "ДРЕВО ПОЛИТИК"},
	"hud.tree.available": {"tr": "Kabul edilebilir: {n}", "en": "Ready to adopt: {n}", "ru": "Доступно к принятию: {n}"},
	"hud.tree.none": {"tr": "Sonraki politikanı planla", "en": "Plan your next policy", "ru": "Планируйте следующую политику"},
	"hud.tree.tip": {
		"tr": "Bütçe, Siyasi Destek ve Bilim ile finanse edilen kalıcı politikalar. Her biri bir kriz direncini kırar.",
		"en": "Permanent policies paid with Budget, Political Support and Science. Each one also counters a crisis resistance.",
		"ru": "Постоянные политики, оплачиваемые Бюджетом, Поддержкой и Наукой. Каждая нейтрализует стойкость кризиса.",
	},
	"hud.key_hint": {"tr": "Kısayol: {key}", "en": "Hotkey: {key}", "ru": "Горячая клавиша: {key}"},

	# --- Data bubbles ---
	"fx.bubble.collect": {"tr": "Toplamak için dokun", "en": "Tap to collect", "ru": "Нажмите для сбора"},

	# --- News ticker chrome ---
	"news.tag": {"tr": "OKYANUS HABERLERİ", "en": "OCEAN NEWS", "ru": "НОВОСТИ ОКЕАНА"},
	"news.chip.breaking": {"tr": "SON DAKİKA", "en": "BREAKING", "ru": "СРОЧНО"},
	"news.chip.good": {"tr": "İYİ HABER", "en": "GOOD NEWS", "ru": "ХОРОШИЕ НОВОСТИ"},
	"news.chip.fact": {"tr": "BİLGİ", "en": "FACT", "ru": "ФАКТ"},
	"news.chip.tip": {"tr": "İPUCU", "en": "TIP", "ru": "СОВЕТ"},
	"news.welcome": {"tr": "AQUASTASIS: Küresel Deniz Koalisyonu dünya okyanuslarının komutasını devraldı", "en": "AQUASTASIS: the Global Marine Coalition takes command of the world's oceans", "ru": "AQUASTASIS: Глобальная морская коалиция берет под контроль Мировой океан"},

	# --- Ambient headlines: a region in trouble ---
	"news.amb.pollution": {"tr": "{region}: kirlilik %{v} seviyesine ulaştı, kıyı uyarısı yapıldı", "en": "{region}: pollution readings climb to {v}%, coastal warnings issued", "ru": "{region}: загрязнение достигло {v}%, объявлено предупреждение"},
	"news.amb.coral": {"tr": "{region}: resiflerde ağarma yayılıyor, mercan sağlığı %{v} seviyesinde", "en": "{region}: bleaching spreads across the reefs, coral health down to {v}%", "ru": "{region}: обесцвечивание рифов, здоровье кораллов упало до {v}%"},
	"news.amb.seagrass": {"tr": "{region}: deniz çayırları seyrekleşiyor, kapsama alanı %{v}", "en": "{region}: seagrass meadows thinning, coverage down to {v}%", "ru": "{region}: морские травы редеют, покрытие упало до {v}%"},
	"news.amb.fish": {"tr": "{region}: balıkçılar boş ağlarla dönüyor, balık stoku %{v}", "en": "{region}: fishers return with empty nets, fish stock at {v}%", "ru": "{region}: рыбаки возвращаются без улова, запасы рыбы: {v}%"},
	"news.amb.collapse": {"tr": "{region}: bilim insanları ekosistemin çökmekte olduğunu belirtiyor", "en": "{region}: scientists warn the ecosystem is collapsing", "ru": "{region}: ученые заявляют об угрозе коллапса экосистемы"},
	"news.amb.worsening": {"tr": "{region}: kriz derinleşiyor, seviye şu an %{v}", "en": "{region}: the crisis deepens, level now {v}%", "ru": "{region}: кризис усугубляется, уровень достиг {v}%"},

	# --- Ambient headlines: a region recovering ---
	"news.amb.clean": {"tr": "{region}: berrak sular geri dönüyor, kriz %{v} seviyesine indi", "en": "{region}: clear water returns, crisis level down to {v}%", "ru": "{region}: вода очищается, уровень кризиса упал до {v}%"},
	"news.amb.seagrass_good": {"tr": "{region}: deniz çayırları %{v} seviyesinde, mavi karbon depolanıyor", "en": "{region}: seagrass meadows thrive at {v}%, locking away blue carbon", "ru": "{region}: морские травы процветают ({v}%), накапливая синий углерод"},
	"news.amb.fish_good": {"tr": "{region}: balık stoku %{v} seviyesine yükseldi, verimli av bildirildi", "en": "{region}: fish stock rebounds to {v}%, cooperatives report better catches", "ru": "{region}: запасы рыбы восстановились до {v}%, уловы растут"},
	"news.amb.coral_good": {"tr": "{region}: dalgıçlar canlı resifleri kaydetti, mercan sağlığı %{v}", "en": "{region}: divers film vibrant reefs, coral health at {v}%", "ru": "{region}: дайверы наблюдают живые рифы, здоровье кораллов {v}%"},
	"news.amb.protected": {"tr": "{region}: devriyeler koruma alanlarını güvenceye aldı, koruma %{v}", "en": "{region}: patrols enforce no-take zones, protection at {v}%", "ru": "{region}: заповедные зоны патрулируются, защита {v}%"},
	"news.amb.aware": {"tr": "{region}: sahil temizliğine katılım rekor kırdı, farkındalık %{v}", "en": "{region}: volunteers flock to beach clean-ups, awareness at {v}%", "ru": "{region}: волонтеры очищают пляжи, осведомленность {v}%"},
	"news.amb.improving": {"tr": "{region}: toparlanma başladı, kriz %{v} seviyesine geriledi", "en": "{region}: the crisis eases to {v}% as recovery takes hold", "ru": "{region}: кризис спадает до {v}% благодаря защитным мерам"},

	# --- Ambient headlines: the global oceans ---
	"news.amb.health_up": {"tr": "Deniz Sağlığı Endeksi %{v} seviyesine yükseldi: okyanuslar yanıt veriyor", "en": "Sea Health Index climbs to {v}%: the oceans are responding", "ru": "Индекс здоровья моря вырос до {v}%: океан восстанавливается"},
	"news.amb.health_down": {"tr": "Deniz Sağlığı Endeksi %{v} seviyesine düştü: acil eylem gerekiyor", "en": "Sea Health Index slips to {v}%: analysts urge faster action", "ru": "Индекс здоровья моря упал до {v}%: требуются срочные меры"},
	"news.amb.temp": {"tr": "Küresel ısınma +{v}°C: okyanus akıntıları ve kutup buzulları baskı altında", "en": "Global warming at +{v}°C; ocean currents and polar ice under stress", "ru": "Потепление достигло +{v}°C; океанические течения и льды под давлением"},
	"news.amb.temp_high": {"tr": "Sıcaklık alarmı: +{v}°C ısınma, denizel sıcak dalgaları sıklaşıyor", "en": "Heat alarm: warming at +{v}°C, marine heatwaves are becoming routine", "ru": "Климатическая тревога: потепление +{v}°C, морские волны тепла стали нормой"},
	"news.amb.goal": {"tr": "Küresel hedef: 2046'ya kadar %60 Deniz Sağlığı. Kalan yıl: {n}", "en": "Global target: Sea Health 60% by 2046. Years left: {n}", "ru": "Глобальная цель: здоровье моря 60% к 2046 году. Осталось лет: {n}"},
	"news.amb.goal_near": {"tr": "Deniz Sağlığı %{v}: %60 küresel hedefe çok az kaldı", "en": "Sea Health at {v}%: the 60% global goal is within reach", "ru": "Здоровье моря {v}%: глобальная цель в 60% уже близка"},
	"news.amb.income_negative": {"tr": "Hazine alarmı: çöken deniz ekonomisi bütçeyi tüketiyor", "en": "Treasury alarm: the failing sea economy is now draining coalition funds", "ru": "Казначейство: кризис океана опустошает финансовый фонд коалиции"},
	"news.amb.resistance": {"tr": "Analistler: kriz direnç geliştirdi ({name}). Yeni politikalar şart", "en": "Analysts: the crisis has adapted ({name}). New policies are needed", "ru": "Аналитики: кризис адаптировался ({name}). Необходимы новые политики"},
	"news.amb.spreads": {"tr": "2026'dan bu yana kaydedilen kriz yayılma olayları: {n}", "en": "Crisis spread events logged since 2026: {n}", "ru": "Вспышек распространения кризиса с 2026 года: {n}"},
	"news.amb.policies": {"tr": "Yürürlükteki koalisyon politikaları: {n}", "en": "Coalition policies in force: {n}", "ru": "Действующих политик коалиции: {n}"},

	# --- Tips (shown once each per game) ---
	"news.tip.bubbles": {"tr": "Bilim ve Siyasi Destek toplamak için denizdeki veri baloncuklarına dokun", "en": "Tap the glowing data bubbles over the sea to collect Science and Political Support", "ru": "Собирайте светящиеся сферы над морем для получения Науки и Поддержки"},
	"news.tip.tree": {"tr": "Kalıcı politikalar kabul etmek için sağ alttaki Politika Ağacı butonuna dokun", "en": "Tap the Policy Tree button to open the Policy Tree and adopt lasting policies", "ru": "Откройте Древо политик, чтобы принять долгосрочные меры"},
	"news.tip.keys": {"tr": "Bölge seçtikten sonra bölge kartından saha operasyonları başlatabilirsin", "en": "Select a region, then tap Field Operations on the region card to intervene", "ru": "Выберите регион и запускайте полевые операции на карточке региона"},
	"news.tip.pause": {"tr": "Plan yapmak için üst bardan duraklat: operasyonlar zaman dururken de çalışır", "en": "Pause on the top bar to plan: operations still work while time stands still", "ru": "Поставьте игру на паузу: вы можете отдавать приказы во время остановки времени"},
	"news.tip.diversify": {"tr": "Tek yönlü stratejiler krizin direnç geliştirmesine yol açar. Hamlelerini çeşitlendir", "en": "A one-sided strategy lets the crisis evolve resistances. Mix your moves", "ru": "Односторонняя тактика ускоряет адаптацию кризиса. Чередуйте действия"},

	# --- Real Global Ocean Facts ---
	"news.fact.biodiversity": {"tr": "Mercan Üçgeni, bilinen tüm mercan türlerinin %76'sına ve 2.000'den fazla resif balığı türüne ev sahipliği yapar", "en": "The Coral Triangle hosts 76% of all known coral species and over 2,000 species of reef fish", "ru": "Коралловый треугольник содержит 76% всех известных видов кораллов и более 2000 видов рифовых рыб"},
	"news.fact.warming": {"tr": "Arktik Okyanusu, kutup büyütmesi etkisiyle dünya ortalamasından yaklaşık üç kat daha hızlı ısınıyor", "en": "The Arctic Ocean is warming nearly three times faster than the global average due to polar amplification", "ru": "Северный Ледовитый океан нагревается почти в три раза быстрее среднемирового уровня"},
	"news.fact.plastic": {"tr": "Büyük Pasifik Çöp Girdabı, Kuzey Pasifik döngüsünde 1.6 milyon km²'lik bir alana yayılmış plastik atıkları barındırır", "en": "The Great Pacific Garbage Patch spans over 1.6 million km² of floating plastic debris in the North Pacific Gyre", "ru": "Большое тихоокеанское мусорное пятно охватывает более 1.6 млн км² пластиковых отходов"},
	"news.fact.posidonia": {"tr": "Kıyı deniz çayırları ve mangrovlar, karbonu okyanus tabanında binlerce yıl boyunca hapseder", "en": "Coastal seagrass meadows and mangroves lock carbon in seabed sediments for thousands of years", "ru": "Прибрежные морские травы и мангры удерживают углерод в донных отложениях тысячелетиями"},
	"news.fact.posidonia_loss": {"tr": "Küresel deniz çayırı alanları son yüzyılda kıyı yapılaşması ve kirlilik yüzünden yaklaşık %30 azaldı", "en": "Global seagrass meadows have shrunk by roughly 30% over the past century due to pollution and coastal development", "ru": "Площадь морских трав в мире сократилась примерно на 30% за последнее столетие"},
	"news.fact.caretta": {"tr": "Deri sırtlı ve yeşil deniz kaplumbağaları, beslenme ve yuvalama alanları arasında okyanusları boydan boya geçer", "en": "Leatherback and green sea turtles cross entire ocean basins between foraging grounds and nesting beaches", "ru": "Кожистые и зеленые морские черепахи пересекают целые океаны между местами кормежки и гнездования"},
	"news.fact.monk_seal": {"tr": "Deniz samurları ve foklar, aşırı çoğalan denizkestanelerini avlayarak kelp ormanlarının hayatta kalmasını sağlar", "en": "Sea otters and seals act as keystone predators, protecting kelp forests from overgrazing by sea urchins", "ru": "Каланы и тюлени являются ключевыми видами, защищающими леса ламинарии от уничтожения морскими ежами"},
	"news.fact.lionfish": {"tr": "Gemilerin balast suları her gün binlerce deniz türünü okyanuslar arasında taşıyarak istilacı tür krizine yol açar", "en": "Ships' ballast water transports thousands of marine species across oceans daily, driving invasive species outbreaks", "ru": "Балластные воды судов ежедневно переносят тысячи видов между океанами, вызывая биологическое загрязнение"},
	"news.fact.mucilage": {"tr": "Tarımsal gübre ve kanalizasyon akıntıları, kıyı denizlerinde oksijensiz ölü bölgeler ve zararlı alg patlamaları yaratır", "en": "Agricultural fertilizer and sewage runoff trigger toxic algal blooms and low-oxygen dead zones along coastlines", "ru": "Стоки удобрений и канализации вызывают токсичное цветение водорослей и мертвые зоны у берегов"},
	"news.fact.overfishing": {"tr": "FAO verilerine göre küresel balık stoklarının üçte birinden fazlası biyolojik olarak sürdürülemez düzeyde avlanıyor", "en": "Over one-third of global marine fish stocks are fished beyond biologically sustainable limits (FAO)", "ru": "Более трети мировых запасов морских рыб вылавливается сверх биологически устойчивых лимитов (ФАО)"},
	"news.fact.renewal": {"tr": "Antarktik Çevresel Akıntı, Atlantik, Pasifik ve Hint okyanuslarını birbirine bağlayan gezegenin en güçlü akıntısıdır", "en": "The Antarctic Circumpolar Current is the planet's strongest current, linking the Atlantic, Pacific and Indian oceans", "ru": "Антарктическое циркумполярное течение — мощнейшее на планете, связывающее Атлантический, Тихий и Индийский океаны"},
	"news.fact.barcelona": {"tr": "2023'te kabul edilen BM Açık Denizler Antlaşması (BBNJ), ulusal sınırların ötesindeki okyanusları koruma altına alır", "en": "The UN High Seas Treaty (BBNJ) establishes legal tools to protect marine biodiversity in international waters", "ru": "Договор ООН об открытом море (BBNJ) создает правовую базу для защиты биоразнообразия в нейтральных водах"},
	"news.fact.summit": {"tr": "Küresel Okyanus Zirveleri, plastik kirliliği, mavi karbon ve 30x30 koruma hedeflerini dünya gündeminin merkezine taşır", "en": "Global Ocean Summits place plastic treaties, blue carbon and 30x30 conservation at the center of climate action", "ru": "Глобальные океанические саммиты ставят защиту океанов и цели 30x30 в центр климатической повестки"},

	# --- Onboarding Directives ---
	"onboarding.title": {"tr": "TAKTİK DİREKTİFLER", "en": "TACTICAL DIRECTIVES", "ru": "ТАКТИЧЕСКИЕ ЗАДАЧИ"},
	"onboarding.step1": {"tr": "1. Haritada bir okyanus bölgesi seç [Dokun]", "en": "1. Select an ocean region [Tap]", "ru": "1. Выберите регион океана [Касание]"},
	"onboarding.step2": {"tr": "2. Bir Veri Baloncuğu topla [Dokun]", "en": "2. Pop a Data Bubble [Tap]", "ru": "2. Соберите сферу данных [Касание]"},
	"onboarding.step3": {"tr": "3. Politika Ağacından karar kabul et", "en": "3. Adopt a Policy in Tree", "ru": "3. Примите политику в древе"},
	"onboarding.step4": {"tr": "4. Zaman akışını başlat (1x)", "en": "4. Unpause simulation (1x)", "ru": "4. Запустите время (1x)"},
	"onboarding.done": {"tr": "TÜM DİREKTİFLER TAMAMLANDI!", "en": "ALL DIRECTIVES COMPLETED!", "ru": "ВСЕ ЗАДАЧИ ВЫПОЛНЕНЫ!"},
	"onboarding.dismiss": {"tr": "Kapat", "en": "Dismiss", "ru": "Закрыть"},

	# --- Monthly pacing & Income ---
	"hud.month_fmt": {"tr": "{year} / {month}", "en": "{year} / {month}", "ru": "{year} / {month}"},
	"hud.rate.monthly": {"tr": "{v}/ay", "en": "{v}/mo", "ru": "{v}/мес"},
	"hud.rate.monthly_tip": {
		"tr": "Aylık net kaynak dengesi (gelir - giderler).",
		"en": "Net monthly balance (income minus maintenance).",
		"ru": "Чистый ежемесячный доход (поступления минус расходы)."
	},
	"hud.trend.fmt": {"tr": "Trend: {trend}", "en": "Trend: {trend}", "ru": "Динамика: {trend}"},
	"hud.region.detail_btn": {"tr": "Detay", "en": "Details", "ru": "Детали"},
	"hud.region.species_title": {"tr": "BAYRAK TÜR", "en": "FLAGSHIP SPECIES", "ru": "ФЛАГОВЫЙ ВИД"},
	"hud.layer.title": {"tr": "Harita Katmanı", "en": "Map Layer", "ru": "Слой карты"},
	"hud.layer.0.name": {"tr": "Standart", "en": "Standard", "ru": "Стандарт"},
	"hud.layer.0.short": {"tr": "Standart", "en": "Standard", "ru": "Стандарт"},
	"hud.layer.0.desc": {
		"tr": "Kirlilik, ekosistem sağlığı ve canlı akıntı görünümü.",
		"en": "Pollution, ecosystem health, and ocean current view.",
		"ru": "Вид загрязнения, состояния экосистемы и течений."
	},
	"hud.layer.1.name": {"tr": "Tehdit & Kalkan", "en": "Threat & Shield", "ru": "Угроза и щит"},
	"hud.layer.1.short": {"tr": "Tehdit", "en": "Threat", "ru": "Угроза"},
	"hud.layer.1.desc": {
		"tr": "Yayılım riski yüksek rotalar parlar; korumasız bölgeler kırmızı/turuncu vurgulanır.",
		"en": "High spread-risk routes glow; unshielded regions highlight in amber/crimson.",
		"ru": "Опасные маршруты светятся; незащищённые регионы выделены красным."
	},
	"hud.layer.2.name": {"tr": "Biyo-Harita", "en": "Bio-Map", "ru": "Био-карта"},
	"hud.layer.2.short": {"tr": "Biyo", "en": "Bio", "ru": "Био"},
	"hud.layer.2.desc": {
		"tr": "Mavi karbon (>%60 çayır) turkuaz, güçlü bayrak tür alanları altın parlar.",
		"en": "Blue-carbon (>60% seagrass) glows turquoise; healthy flagship habitats glow gold.",
		"ru": "Голубой углерод (>60% водорослей) — бирюзовый; флаговые виды — золотой."
	},
	"hud.layer.pill_fmt": {"tr": "{name} — {desc}", "en": "{name} — {desc}", "ru": "{name} — {desc}"},
	"hud.fleet.btn": {"tr": "Filoyu Sevk Et", "en": "Dispatch Fleet", "ru": "Отправить флот"},
	"hud.fleet.ready": {"tr": "Acil Filo Hazır", "en": "Fleet Ready", "ru": "Флот готов"},
	"hud.fleet.transit_fmt": {"tr": "Filo Yolda ({eta} ay)", "en": "En Route ({eta} mo)", "ru": "В пути ({eta} мес.)"},
	"hud.fleet.cd_fmt": {"tr": "Soğuma ({left} ay)", "en": "Cooldown ({left} mo)", "ru": "Восст. ({left} мес.)"},
	"hud.fleet.need_hq": {"tr": "HQ Krizi < %50 Gerekli", "en": "Needs HQ Crisis < 50%", "ru": "Кризис штаба < 50%"},
	"hud.fleet.same_hq": {"tr": "Uzak Bölge Seç", "en": "Select Non-HQ", "ru": "Выберите другой регион"},
	"hud.fleet.no_budget": {"tr": "Yetersiz Bütçe ({cost})", "en": "Low Budget ({cost})", "ru": "Мало бюджета ({cost})"},
	"hud.fleet.tip": {
		"tr": "HQ krizi %50 altındayken bu bölgeye rota boyunca Acil Müdahale Filosu sevk eder ({cost} Bütçe).",
		"en": "When HQ crisis is below 50%, dispatches an Emergency Fleet along routes ({cost} Budget).",
		"ru": "При кризисе штаба < 50% отправляет экстренный флот по маршрутам к этому региону."
	},
	"hud.combo.title": {"tr": "Tam Seferberlik", "en": "Full Mobilization", "ru": "Полная мобилизация"},
	"hud.combo.active_fmt": {"tr": "3/3 Aktif · {left} ay", "en": "3/3 Active · {left} mo", "ru": "3/3 Активно · {left} мес."},
	"hud.combo.prog_fmt": {"tr": "Sinerji: {n}/3", "en": "Synergy: {n}/3", "ru": "Синергия: {n}/3"},
	"hud.combo.banner_fmt": {"tr": "3/3 Tam Seferberlik ({left} ay)", "en": "3/3 Full Mobilization ({left} mo)", "ru": "3/3 Полная мобилизация ({left} мес.)"},
	"hud.combo.tip": {
		"tr": "10 ay içinde aynı bölgede 3 farklı operasyon yapılırsa 12 ay boyunca yayılım riski %50 azalır.",
		"en": "Run all 3 distinct operations within 10 months to gain a 12-month 50% spread shield.",
		"ru": "Выполните 3 разные операции за 10 мес., чтобы снизить распространение на 50% на 12 мес."
	},
	"map.badge.shield": {"tr": "[KALKAN]", "en": "[SHIELD]", "ru": "[ЩИТ]"},
	"map.badge.alert": {"tr": "[!]", "en": "[!]", "ru": "[!]"},
	"hud.trend.tip": {
		"tr": "Aylık kirlilik değişimi. Negatif değerler iyileşmeyi, pozitif değerler kirlilik artışını gösterir.",
		"en": "Monthly pollution delta. Negative values mean recovery; positive values mean worsening crisis.",
		"ru": "Ежемесячное изменение загрязнения. Отрицательные значения — улучшение, положительные — ухудшение."
	},
	"hud.species.caretta_nests": {"tr": "Deniz Kaplumbağaları: {n}", "en": "Sea Turtles: {n}", "ru": "Морские черепахи: {n}"},
	"hud.species.monk_seals": {"tr": "Deniz Memelileri: {n}", "en": "Marine Mammals: {n}", "ru": "Морские млекопитающие: {n}"},

	# --- Interactive Mission Directives ---
	"directive.title": {"tr": "HAREKAT DİREKTİFİ", "en": "MISSION DIRECTIVE", "ru": "ДИРЕКТИВА МИССИИ"},
	"directive.step_fmt": {"tr": "ADIM {cur} / {total}", "en": "STEP {cur} / {total}", "ru": "ШАГ {cur} / {total}"},
	"directive.skip": {"tr": "Rehberi Atla", "en": "Skip Tutorial", "ru": "Пропустить"},
	"directive.btn.start": {"tr": "▶ 1x Başlat", "en": "▶ Start 1x", "ru": "▶ Запустить 1x"},
	"directive.step1": {
		"tr": "🎯 Haritada [KARARGAH] bölgesine dokun. (Burası komuta üssümüz! Kriz çöküş sınırını aşarsa koalisyon kaybeder.)",
		"en": "🎯 Tap your [HEADQUARTERS] region on the map. (Our command base! If crisis exceeds the limit, the coalition collapses.)",
		"ru": "🎯 Нажмите на регион [ШТАБ] на карте. (Главная база! Если кризис превысит лимит, коалиция падёт.)"
	},
	"directive.step2": {
		"tr": "🧹 Bölge kartından [Temizlik Operasyonu] butonuna dokun. (Kirliliği hızla düşürür.)",
		"en": "🧹 Tap [Cleanup Operation] on the region card. (Quickly cuts regional pollution.)",
		"ru": "🧹 Запустите [Очистку] на карточке региона. (Быстро снижает загрязнение региона.)"
	},
	"directive.step3": {
		"tr": "🔬 Denizde yüzen parlak [Veri Baloncuğu]na dokun. (Toplanan Bilim ile yeni teknolojiler araştıracaksın.)",
		"en": "🔬 Tap the floating glowing [Data Bubble] on the sea. (Collected Science unlocks advanced eco-tech.)",
		"ru": "🔬 Нажмите на светящуюся [Сферу Данных] над морем. (Очки науки нужны для исследований технологий.)"
	},
	"directive.step4": {
		"tr": "📜 Sağ alttaki [Politika Ağacı] butonuna dokun ve ilk çevreci kanununu kabul et. (Kalıcı koruma ve altyapı kurar.)",
		"en": "📜 Tap the [Policy Tree] button and adopt your first policy. (Establishes lasting marine protections.)",
		"ru": "📜 Откройте [Древо Политик] и примите первый закон. (Создает долгосрочные морские заповедники.)"
	},
	"directive.step5": {
		"tr": "⏱️ Üst bardan zaman akışını başlat ([1x]). Hedef: 2046 yılına kadar Deniz Sağlığını %60'a ulaştır!",
		"en": "⏱️ Start time flow ([1x]) on the top bar. Mission Goal: Reach ≥ 60% Sea Health before 2046!",
		"ru": "⏱️ Запустите время ([1x]) на верхней панели. Цель: довести здоровье моря до ≥ 60% к 2046 году!"
	},
	"directive.done": {
		"tr": "🎉 EĞİTİM TAMAMLANDI! Küresel Deniz Koalisyonu Emrinde. İyi şanslar Komutan!",
		"en": "🎉 DIRECTIVES COMPLETE! The Global Marine Coalition is in your hands. Good luck Commander!",
		"ru": "🎉 ОБУЧЕНИЕ ЗАВЕРШЕНО! Глобальная морская коалиция под вашим командованием. Удачи!"
	},

	# --- Tactical Field Manual (Clean [?] Modal) ---
	"manual.title": {"tr": "KÜRESEL OKYANUS HAREKAT KILAVUZU", "en": "GLOBAL OCEAN FIELD MANUAL", "ru": "РУКОВОДСТВО ГЛОБАЛЬНОЙ ОПЕРАЦИИ"},
	"manual.close": {"tr": "Anladım (Kapat)", "en": "Understood (Close)", "ru": "Понятно (Закрыть)"},
	"manual.sec1.title": {"tr": "1. STRATEJİK KAYNAKLAR", "en": "1. CORE RESOURCES", "ru": "1. СТРАТЕГИЧЕСКИЕ РЕСУРСЫ"},
	"manual.sec1.body": {
		"tr": "• 💰 Bütçe: Temizlik ve altyapı için harcanır. Sağlıklı okyanus ekonomisinden aylık gelir sağlar.\n• 🏛️ Siyasi Destek: Yasalar, kotalar ve diplomatik kararlar için kullanılır. Farkındalık arttıkça büyür.\n• 🔬 Bilim Puanı: Denizde yüzen camgöbeği baloncuklardan toplanır. Teknoloji ağacı ve karşı-aşı için harcanır.",
		"en": "• 💰 Budget: Spent on cleanups & infrastructure. Earned monthly from a healthy marine economy.\n• 🏛️ Political Support: Spent on laws, quotas, and treaties. Grown by raising public awareness.\n• 🔬 Science Points: Popped from cyan sea bubbles. Spent on Tech Tree research & mutation cures.",
		"ru": "• 💰 Бюджет: Тратится на очистку и инфраструктуру. Поступает от здоровой морской экономики.\n• 🏛️ Поддержка: Нужна для законов, квот и соглашений. Растет при высокой осведомленности.\n• 🔬 Очки Науки: Собираются со сфер над морем. Нужны для древа технологий и вакцин."
	},
	"manual.sec2.title": {"tr": "2. KARARGAH & KÜRESEL KRİZ TEHDİDİ", "en": "2. HEADQUARTERS & GLOBAL THREATS", "ru": "2. ШТАБ-КВАРТИРА И УГРОЗЫ КРИЗИСА"},
	"manual.sec2.body": {
		"tr": "• ⚓ Karargah Kuralı: Seçtiğiniz karargah bölgesi koalisyon merkezidir. Kriz seviyesi çöküş sınırına ulaşırsa derhal KAYBEDERSİNİZ!\n• 🌡️ Küresel Isınma: Sıcaklık +4.0°C sınırına ulaşırsa okyanus ekosistemi geri dönülemez şekilde çöker.\n• 🧬 Kriz Dirençleri: Sürekli tek tip eylem yaparsanız Kriz mutasyon geçirir ve o taktiğe bağışıklık kazanır.",
		"en": "• ⚓ HQ Rule: Your chosen HQ region is Coalition Command. If its crisis reaches the collapse limit, you instantly LOSE!\n• 🌡️ Global Warming: If sea temp hits +4.0°C, the global ocean triggers irreversible biosphere collapse.\n• 🧬 Crisis Mutations: Spamming one action provokes genetic resistance, nullifying that strategy.",
		"ru": "• ⚓ Правило штаба: Выбранный регион — главный штаб. Если кризис там достигнет порога, вы проиграли!\n• 🌡️ Потепление: При температуре +4.0°C морская биосфера погибает безвозвратно.\n• 🧬 Мутации кризиса: Однотипная тактика провоцирует устойчивость кризиса к вашим действиям."
	},
	"manual.sec3.title": {"tr": "3. SAHA OPERASYONLARI VE DOKUNMATİK KONTROLLER", "en": "3. FIELD OPERATIONS & TOUCH CONTROLS", "ru": "3. ОПЕРАЦИИ И СЕНСОРНОЕ УПРАВЛЕНИЕ"},
	"manual.sec3.body": {
		"tr": "• 🧹 Temizlik Operasyonu: Seçili bölgedeki kirliliği bütçe harcayarak anında düşürür.\n• 🛡️ Deniz Devriyesi: Kaçak balıkçılığı önler, koruma kalkanını artırır ve krizi doğrudan düşürür.\n• 📢 Farkındalık Kampanyası: Kıyı halkını eğitir, farkındalık artırır ve krizi azaltır.\n• 📜 Politika Ağacı: Kalıcı 24 farklı çevre yasasını ve bilimsel projeyi açar.\n• 🤏 Harita Kontrolü: İki parmakla yakınlaştırın, tek parmakla kaydırın.",
		"en": "• 🧹 Cleanup Operation: Instantly cleans regional waste using budget.\n• 🛡️ Marine Patrol: Enforces no-take zones, raises marine protection, and directly cuts crisis.\n• 📢 Awareness Campaign: Educates coastal public, boosting support and lowering crisis.\n• 📜 Policy Tree: Opens 24 permanent marine laws and research projects.\n• 🤏 Map Controls: Pinch with two fingers to zoom, drag with one finger to pan.",
		"ru": "• 🧹 Операция очистки: Срочно убирает загрязнение региона за бюджет.\n• 🛡️ Морской патруль: Пресекает браконьерство, повышая охрану моря и снижая кризис.\n• 📢 Просвещение: Повышает осведомленность жителей, поддержку и снижает кризис.\n• 📜 Древо политик: Открывает 24 закона и научно-исследовательских проекта.\n• 🤏 Управление картой: Масштабируйте двумя пальцами, двигайте одним."
	},
	"manual.sec4.title": {"tr": "4. KÜRESEL OKYANUS ZİRVELERİ & 2046 ZAFERİ", "en": "4. GLOBAL OCEAN SUMMITS & 2046 VICTORY", "ru": "4. ОКЕАНИЧЕСКИЕ САММИТЫ И ПОБЕДА 2046"},
	"manual.sec4.body": {
		"tr": "• 🏛️ Zirveler: 2031, 2036 ve 2041 yıllarında toplanır. Başarılıysanız büyük fonlar, başarısızsanız zorlu tavizler gelir.\n• 🐢 Biyoçeşitlilik: Kirlilik azaldıkça ve koruma arttıkça 12 okyanus bölgesindeki bayrak türler çoğalır.\n• 🏆 Zafer Şartı: 2046 yılına kadar Deniz Sağlığı Endeksini %60 üzerine çıkarın ya da tüm bölgeleri %25 kriz altına indirin!",
		"en": "• 🏛️ Summits: Convene in 2031, 2036, and 2041. Success grants massive funds; failure forces concessions.\n• 🐢 Biodiversity: Lowering pollution and raising protection restores flagship species across all 12 ocean regions.\n• 🏆 Victory: Sustain Global Sea Health ≥ 60% (or all regions < 25% crisis) by 2046 to save the oceans!",
		"ru": "• 🏛️ Саммиты: Проходят в 2031, 2036 и 2041 годах. Успех дает гранты, провал — штрафы.\n• 🐢 Биоразнообразие: При снижении загрязнения популяции флаговых видов растут во всех 12 регионах.\n• 🏆 Победа: Достигните здоровья моря ≥ 60% к 2046 году, чтобы спасти Мировой океан!"
	},

	# --- Resource Tooltips ---
	"res.budget.tip": {
		"tr": "[b]BÜTÇE[/b]\n[color=#38bdf8]Nasıl Kazanılır:[/color] Sağlıklı balık stokları ve sürdürülebilir ekonomi politikalarından gelen aylık koalisyon katkıları.\n[color=#f59e0b]Kullanım Alanı:[/color] Fiziksel altyapı, Deniz Koruma Alanları, atık filtreleri ve bölgesel acil temizlikler.",
		"en": "[b]BUDGET[/b]\n[color=#38bdf8]How to Earn:[/color] Monthly coalition tax income scaling with healthy fish stocks & blue economy policies.\n[color=#f59e0b]Used For:[/color] Physical infrastructure, Marine Protected Areas, wastewater filtration, and regional cleanups.",
		"ru": "[b]БЮДЖЕТ[/b]\n[color=#38bdf8]Как заработать:[/color] Ежемесячные взносы коалиции, зависящие от запасов рыбы и мер синей экономики.\n[color=#f59e0b]На что тратить:[/color] Инфраструктура, морские заповедники, фильтры стоков и локальная очистка."
	},
	"res.political.tip": {
		"tr": "[b]POLİTİK DESTEK[/b]\n[color=#38bdf8]Nasıl Kazanılır:[/color] Kehribar baloncukları toplama, yüksek bölgesel farkındalık ve diplomatik kararlar.\n[color=#f59e0b]Kullanım Alanı:[/color] Yasaklar (tek kullanımlık plastik yasağı), uluslararası antlaşmalar ve denetim kotaları.",
		"en": "[b]POLITICAL SUPPORT[/b]\n[color=#38bdf8]How to Earn:[/color] Popping amber data bubbles, high regional public awareness, and diplomatic summit choices.\n[color=#f59e0b]Used For:[/color] Enacting bans (single-use plastics), international treaties, and coastal patrol quotas.",
		"ru": "[b]ПОЛИТИЧЕСКАЯ ПОДДЕРЖКА[/b]\n[color=#38bdf8]Как заработать:[/color] Сбор янтарных сфер, высокая осведомленность регионов и дипломатические решения.\n[color=#f59e0b]На что тратить:[/color] Запреты (одноразовый пластик), международные соглашения и квоты патрулей."
	},
	"res.science.tip": {
		"tr": "[b]BİLİM PUANI[/b]\n[color=#38bdf8]Nasıl Kazanılır:[/color] Denizde beliren camgöbeği araştırma baloncuklarını toplama ve uydu izleme ağları.\n[color=#f59e0b]Kullanım Alanı:[/color] İleri kademe teknolojileri açma, Kriz Dirençlerini nötralize etme ve derin deniz projeleri.",
		"en": "[b]SCIENCE POINTS[/b]\n[color=#38bdf8]How to Earn:[/color] Collecting cyan research bubbles across the sea and satellite monitoring nodes.\n[color=#f59e0b]Used For:[/color] Unlocking advanced tier-2/3 tech, synthesizing counter-strategies against mutations, and deep-sea projects.",
		"ru": "[b]ОЧКИ НАУКИ[/b]\n[color=#38bdf8]Как заработать:[/color] Сбор бирюзовых научных сфер в море и спутниковые сети мониторинга.\n[color=#f59e0b]На что тратить:[/color] Передовые технологии 2-го/3-го уровней, нейтрализация мутаций кризиса и глубоководные проекты."
	},

	# --- 3-Card Tactical Briefing Modal ---
	"briefing.modal_title": {"tr": "KÜRESEL OKYANUS HAREKÂT BRİFİNGİ", "en": "GLOBAL OCEAN MISSION BRIEFING", "ru": "ТАКТИЧЕСКИЙ БРИФИНГ МИССИИ"},
	"briefing.card1.title": {"tr": "1. TEHDİT: OKYANUSLARIN ÇÖKÜŞÜ", "en": "1. THE THREAT: OCEAN COLLAPSE", "ru": "1. УГРОЗА: КОЛЛАПС ОКЕАНА"},
	"briefing.card1.text": {
		"tr": "Kirlilik, aşırı ısınma ve habitat kaybı okyanus akıntıları ve yoğun gemi hatları boyunca hızla yayılıyor.\n\n• [color=#f87171]Kayıp Şartı:[/color] Küresel ısınma +4.0°C'ye ulaşırsa veya Deniz Sağlığı %10'un altına düşerse okyanuslar çöker!\n• [color=#4ade80]Kazanma Şartı:[/color] 2046 yılına kadar Deniz Sağlığını en az %60'a ulaştırın ya da her bölgedeki krizi %25'in altına çekin.",
		"en": "Pollution, extreme heating, and habitat loss spread rapidly along global ocean currents and shipping lanes.\n\n• [color=#f87171]Defeat:[/color] If warming reaches +4.0°C or Sea Health falls below 10%, the ecosystem collapses!\n• [color=#4ade80]Victory:[/color] Raise Sea Health to at least 60% by 2046, or push crisis below 25% across every single region.",
		"ru": "Загрязнение, перегрев и гибель биоты стремительно разносятся течениями и судоходными маршрутами.\n\n• [color=#f87171]Поражение:[/color] Потепление до +4.0°C или падение здоровья моря ниже 10% разрушит экосистему!\n• [color=#4ade80]Победа:[/color] Достигните 60% здоровья моря к 2046 году или снизьте кризис ниже 25% во всех регионах."
	},
	"briefing.card2.title": {"tr": "2. ÜÇ STRATEJİK KAYNAK", "en": "2. THREE CORE RESOURCES", "ru": "2. ТРИ КЛЮЧЕВЫХ РЕСУРСА"},
	"briefing.card2.text": {
		"tr": "Başarı için 3 kaynağı dengeli yönetmelisiniz:\n\n• [color=#38bdf8]BÜTÇE:[/color] Sağlıklı balık stoklarından aylık akar. Filtreler, koruma alanları ve temizlik ekipleri finanse eder.\n• [color=#f59e0b]POLİTİK DESTEK:[/color] Halk farkındalığından beslenir. Yasaklar, balıkçılık kotaları ve antlaşmalar için zorunludur.\n• [color=#2dd4bf]BİLİM PUANI:[/color] Denizdeki araştırma baloncuklarından toplanır. İleri teknolojileri açar ve mutasyonları kırar.",
		"en": "Manage three core resources in harmony:\n\n• [color=#38bdf8]BUDGET:[/color] Flows monthly from healthy fish stocks. Builds wastewater filters, MPAs, and cleanup teams.\n• [color=#f59e0b]POLITICAL SUPPORT:[/color] Driven by public awareness. Enacts plastic bans, fishing quotas, and international treaties.\n• [color=#2dd4bf]SCIENCE:[/color] Collected from marine data bubbles. Unlocks high-tech nodes and synthesizes counter-cures.",
		"ru": "Сбалансируйте использование трех ключевых ресурсов:\n\n• [color=#38bdf8]БЮДЖЕТ:[/color] Поступает от рыбных запасов. Строит фильтры стоков, заповедники и команды очистки.\n• [color=#f59e0b]ПОДДЕРЖКА:[/color] Растет от осведомленности. Принимает законы, квоты вылова и соглашения.\n• [color=#2dd4bf]НАУКА:[/color] Сбор морских сфер данных. Открывает технологии и нейтрализует мутации."
	},
	"briefing.card3.title": {"tr": "3. TAKTİKLER & KRİZ DİRENCİ", "en": "3. TACTICS & CRISIS MUTATION", "ru": "3. ТАКТИКА И МУТАЦИИ КРИЗИСА"},
	"briefing.card3.text": {
		"tr": "• [b]Bölge Teşhisi:[/b] Haritada bir okyanus bölgesine dokunarak kriz kaynaklarını ve aylık akıntı baskısını inceleyin.\n• [b]Politika Ağacı:[/b] Kalıcı çözümler devreye alın. İleri kademeler Bilim Puanı da gerektirir.\n• [b]Kriz Adaptasyonu (DNA):[/b] Sadece tek bir yönteme yüklenirseniz Kriz direnç geliştirir! Çeşitli stratejiler uygulayın veya Direnci Bilim ile sentezleyerek yok edin.",
		"en": "• [b]Regional Diagnosis:[/b] Tap any ocean region on the map to inspect its crisis drivers and monthly current pressure.\n• [b]Policy Tree:[/b] Enact lasting reforms. Advanced tiers require hybrid Science Points.\n• [b]Crisis Adaptation (DNA):[/b] Relying solely on one method causes the crisis to evolve resistance! Diversify your moves or spend Science to synthesize counter-cures.",
		"ru": "• [b]Диагностика:[/b] Нажмите на регион, чтобы изучить источники кризиса и давление течений.\n• [b]Древо политик:[/b] Принимайте долгосрочные меры. Старшие уровни требуют очков науки.\n• [b]Мутации кризиса (ДНК):[/b] Спам одного действия провоцирует мутацию кризиса! Чередуйте тактики или синтезируйте вакцины за очки науки."
	},
	"briefing.btn.next": {"tr": "İleri →", "en": "Next →", "ru": "Далее →"},
	"briefing.btn.prev": {"tr": "← Geri", "en": "← Back", "ru": "← Назад"},
	"briefing.btn.start": {"tr": "GÖREVE BAŞLA", "en": "START MISSION", "ru": "НАЧАТЬ МИССИЮ"},
	"briefing.btn.skip": {"tr": "Brifingi Geç", "en": "Skip Briefing", "ru": "Пропустить"},
	"briefing.step_fmt": {"tr": "{cur} / {total}", "en": "{cur} / {total}", "ru": "{cur} / {total}"},

	# --- 12 Global Regional Crisis Traits ---
	"region.trait.title": {"tr": "BÖLGESEL KRİZ NİTELİĞİ", "en": "REGIONAL CRISIS TRAIT", "ru": "ОСОБЕННОСТЬ РЕГИОНА"},
	"region.north_atlantic.trait": {"tr": "Yoğun Konteyner Rotaları ve Endüstriyel Av Baskısı", "en": "Dense Container Lanes & Industrial Fishing Pressure", "ru": "Плотные судоходные пути и промышленный вылов"},
	"region.south_atlantic.trait": {"tr": "Açık Deniz Petrol Hatları ve Güney Akıntı Koridoru", "en": "Offshore Oil Routes & South Atlantic Gyre Drift", "ru": "Нефтяные маршруты и южный круговорот течений"},
	"region.caribbean.trait": {"tr": "Derin Deniz Sondajı, Kasırga Kuşağı ve Resif Stresi", "en": "Offshore Drilling, Hurricane Belt & Reef Stress", "ru": "Нефтедобыча, пояс ураганов и стресс рифов"},
	"region.mediterranean.trait": {"tr": "Yarı Kapalı Deniz, Yoğun Kıyı Nüfusu ve Kanal Trafiği", "en": "Semi-Enclosed Sea, High Coastal Pop & Canal Traffic", "ru": "Полузамкнутое море, плотное население и трафик"},
	"region.red_arabian.trait": {"tr": "Süveyş-Hürmüz Tanker Koridoru ve Yüksek Termal Stres", "en": "Suez-Hormuz Tanker Corridor & High Thermal Stress", "ru": "Танкерный коридор Суэц-Ормуз и тепловой стресс"},
	"region.indian.trait": {"tr": "Muson Nehir Girdileri ve Küresel Transit Gemi Hatları", "en": "Monsoon River Inflows & Global Transit Shipping", "ru": "Муссонные речные стоки и транзитное судоходство"},
	"region.coral_triangle.trait": {"tr": "Dünya Mercan Merkezi, Plastik Akışı ve Isı Hassasiyeti", "en": "Global Coral Epicenter, Plastic Inflow & Heat Sensitivity", "ru": "Эпицентр кораллов, пластик и уязвимость к теплу"},
	"region.east_asian.trait": {"tr": "Mega Limanlar, Sanayi Deşarjı ve Nehir Plastiği", "en": "Mega-Ports, Industrial Discharge & River Plastics", "ru": "Мегапорты, промышленные стоки и речной пластик"},
	"region.north_pacific.trait": {"tr": "Kuroshio Akıntısı, Çöp Girdabı ve Hayalet Ağlar", "en": "Kuroshio Current, Garbage Patch & Ghost Gear", "ru": "Течение Куросио, мусорное пятно и сети-призраки"},
	"region.south_pacific.trait": {"tr": "Büyük Set Resifi Ağarma Riski ve İklim Duyarlılığı", "en": "Great Barrier Reef Bleaching Risk & Heat Sensitivity", "ru": "Риск обесцвечивания Большого Барьерного рифа"},
	"region.arctic.trait": {"tr": "Kutup Buz Erimesi, Çok Yüksek Isı Hassasiyeti ve Yeni Rotalar", "en": "Polar Ice Melt, Extreme Heat Sensitivity & New Lanes", "ru": "Таяние льдов, высокая чувствительность к теплу"},
	"region.southern.trait": {"tr": "Antarktik Çevresel Akıntı ve Kril Besin Zinciri Baskısı", "en": "Antarctic Circumpolar Current & Krill Food-Web Stress", "ru": "Циркумполярное течение и вылов криля"},

	# --- Monthly Dynamics Breakdown ---
	"hud.breakdown.title": {"tr": "AYLIK DEĞİŞİM DİNAMİKLERİ", "en": "MONTHLY DYNAMICS BREAKDOWN", "ru": "ЕЖЕМЕСЯЧНАЯ ДИНАМИКА"},
	"hud.breakdown.shipping": {"tr": "Gemi Hatları Girişi", "en": "Shipping Lanes Inflow", "ru": "Судоходные маршруты"},
	"hud.breakdown.currents": {"tr": "Komşu Akıntı Baskısı", "en": "Neighbor Current Inflow", "ru": "Приток соседних течений"},
	"hud.breakdown.coastal": {"tr": "Yerel Kıyı Kaynakları", "en": "Local Coastal Sources", "ru": "Местные прибрежные стоки"},
	"hud.breakdown.heat": {"tr": "Termal İklim Stresi", "en": "Thermal Climate Stress", "ru": "Термический стресс"},
	"hud.breakdown.shield": {"tr": "Koruma ve Bilinç Kalkanı", "en": "Protection & Awareness Shield", "ru": "Защита и гражданский щит"},
	"hud.breakdown.net": {"tr": "Net Aylık Değişim", "en": "Net Monthly Change", "ru": "Чистое изменение"},

	# --- Repeatable Science Projects & Toasts ---
	"toast.project.bio_algae": {"tr": "Biyo-Alg Karbon Depolaması devreye alındı (sıcaklık düşürüldü, +%4.5 Deniz Çayırı)!", "en": "Bio-Algae Sequestration deployed (temperature lowered, +4.5% Seagrass)!", "ru": "Био-водоросли развернуты (температура снижена, +4.5% морских трав)!"},
	"toast.project.drone_swarm": {"tr": "Otonom Temizlik Dron Filosu en kritik bölgeyi temizledi (-%12 Kirlilik, +35 Bütçe)!", "en": "Autonomous Drone Swarm cleaned the worst crisis hotspot (-12% Pollution, +35 Budget)!", "ru": "Рой дронов очистил критический очаг (-12% загрязнения, +35 бюджета)!"},
	"tree.counter_synth.btn": {"tr": "🧪 Sentezle (-{cost} Bilim)", "en": "🧪 Synthesize (-{cost} Science)", "ru": "🧪 Синтез (-{cost} науки)"},
	"tree.counter_synth.tip": {"tr": "Bu kriz mutasyonunu nötralize etmek ve kalıcı bağışıklık kazanmak için Bilim Puanı harca.", "en": "Spend Science Points to neutralize this crisis mutation and gain permanent immunity.", "ru": "Потратьте очки науки, чтобы нейтрализовать мутацию и получить иммунитет."},
	"tree.projects.title": {"tr": "TEKRARLANABİLİR BİLİM PROJELERİ", "en": "REPEATABLE SCIENCE PROJECTS", "ru": "ПОВТОРЯЕМЫЕ НАУЧНЫЕ ПРОЕКТЫ"},
	"tree.projects.ready": {"tr": "Hazır", "en": "Ready", "ru": "Готово"},
	"tree.projects.cooldown": {"tr": "Bekleme: {n} ay", "en": "Cooldown: {n} mo", "ru": "Перезарядка: {n} мес"},
	"project.bio_algae.name": {"tr": "Biyo-Alg Karbon Depolama", "en": "Bio-Algae Carbon Sequestration", "ru": "Связывание углерода водоросленным покровом"},
	"project.bio_algae.desc": {"tr": "Özel genetik alg suşları salarak deniz sıcaklığını düşürür (-0.03°C ila -0.06°C) ve tüm okyanuslarda deniz çayırlarını %4.5 yeniler (40 Bilim, 25 Bütçe).", "en": "Releases engineered algae to cool sea temperatures (-0.03°C to -0.06°C) and restore 4.5% seagrass across all regions (40 Science, 25 Budget).", "ru": "Снижает температуру моря (-0.03°C .. -0.06°C) и восстанавливает 4.5% морских трав во всех регионах (40 науки, 25 бюджета)."},
	"project.drone_swarm.name": {"tr": "Otonom Temizlik Dron Sürüsü", "en": "Autonomous Drone Swarms", "ru": "Автономные рои дронов-очистителей"},
	"project.drone_swarm.desc": {"tr": "En yüksek kirliliğe sahip bölgede kirliliği %12 azaltır; toplanan polimerler +35 Bütçe ve +12 Politik Destek sağlar (30 Bilim, 20 Bütçe).", "en": "Cleans 12% pollution in the most damaged region, yielding +35 Budget and +12 Political Support (30 Science, 20 Budget).", "ru": "Устраняет 12% загрязнения в худшем регионе и приносит +35 бюджета и +12 поддержки (30 науки, 20 бюджета)."},

	# --- Difficulty Settings ---
	"diff.title": {"tr": "ZORLUK DERECESİ", "en": "DIFFICULTY LEVEL", "ru": "УРОВЕНЬ СЛОЖНОСТИ"},
	"diff.cadet.name": {"tr": "Kadet (Kolay)", "en": "Cadet (Easy)", "ru": "Кадет (Легко)"},
	"diff.cadet.desc": {"tr": "Geniş başlangıç bütçesi (%150) ve yavaş kriz yayılımı (%75). Karargah %92 dirence sahiptir. Yeni komutanlar için idealdir.", "en": "Abundant starting budget (150%) and slower crisis spread (75%). HQ holds 92% resistance. Ideal for new commanders.", "ru": "Щедрый начальный бюджет (150%) и замедленный кризис (75%). Штаб держит до 92% порога. Идеально для новичков."},
	"diff.commander.name": {"tr": "Komutan (Normal)", "en": "Commander (Normal)", "ru": "Командир (Нормально)"},
	"diff.commander.desc": {"tr": "Dengeli kaynaklar ve standart küresel okyanus dinamikleri. Karargah çöküş limiti: %80.", "en": "Balanced resources and standard global ocean dynamics. HQ collapse limit: 80%.", "ru": "Сбалансированные ресурсы и стандартная динамика Мирового океана. Порог штаба: 80%."},
	"diff.admiral.name": {"tr": "Amiral (Zor)", "en": "Admiral (Hard)", "ru": "Адмирал (Сложно)"},
	"diff.admiral.desc": {"tr": "Kısıtlı başlangıç kaynakları (%75), saldırgan kriz yayılımı (%125) ve %72'de çöken Karargah. Usta stratejistler için acımasız sınav.", "en": "Scarce starting resources (75%), aggressive crisis spread (125%), and HQ collapses at 72%. Unforgiving test for veteran tacticians.", "ru": "Скудные ресурсы (75%), агрессивный кризис (125%) и падение штаба уже при 72%. Суровое испытание для ветеранов."},
	"hud.diff.badge": {"tr": "Zorluk: {diff}", "en": "Diff: {diff}", "ru": "Сложность: {diff}"},

	# --- DEFCON Readiness Barometer ---
	"hud.defcon.title": {"tr": "EKOLOJİK DEFCON HAZIRLIĞI", "en": "ECOLOGICAL DEFCON STATUS", "ru": "ЭКОЛОГИЧЕСКИЙ СТАТУС DEFCON"},
	"hud.defcon.5": {"tr": "DEFCON 5 — DENGELİ", "en": "DEFCON 5 — STABLE", "ru": "DEFCON 5 — СТАБИЛЬНО"},
	"hud.defcon.5.desc": {"tr": "Dünya okyanusları kontrol altında. Ekosistem dengesi korunuyor.", "en": "Global oceans are stable. Ecosystem balance maintained.", "ru": "Мировой океан стабилен. Экосистема в норме."},
	"hud.defcon.4": {"tr": "DEFCON 4 — UYARI", "en": "DEFCON 4 — GUARD", "ru": "DEFCON 4 — ВНИМАНИЕ"},
	"hud.defcon.4.desc": {"tr": "Bölgesel sıcaklık ve kirlilik baskısı artıyor. Tedbirler artırılmalı.", "en": "Regional warming and pollution stress rising. Precautionary actions required.", "ru": "Локальное потепление и загрязнение растут. Требуются меры."},
	"hud.defcon.3": {"tr": "DEFCON 3 — YÜKSEK ALARM", "en": "DEFCON 3 — ELEVATED", "ru": "DEFCON 3 — ПОВЫШЕННАЯ ГОТОВНОСТЬ"},
	"hud.defcon.3.desc": {"tr": "Okyanuslar arası yayılan kriz riski. Müdahaleler hızlandırılmalı.", "en": "Ocean-wide crisis threat spreading. Accelerate field interventions.", "ru": "Угроза масштабного кризиса. Ускорьте вмешательство."},
	"hud.defcon.2": {"tr": "DEFCON 2 — ACİL KRİZ", "en": "DEFCON 2 — SEVERE", "ru": "DEFCON 2 — ВЫСОКАЯ ОПАСНОСТЬ"},
	"hud.defcon.2.desc": {"tr": "Kritik mercan ve balık kayıpları. Karargah bölgesi baskı altında!", "en": "Critical coral and fish stock collapse. Headquarters under heavy threat!", "ru": "Критическая потеря кораллов и рыбы. Штаб под угрозой!"},
	"hud.defcon.1": {"tr": "DEFCON 1 — TOPYEKÜN ÇÖKÜŞ", "en": "DEFCON 1 — CATASTROPHIC", "ru": "DEFCON 1 — КАТАСТРОФА"},
	"hud.defcon.1.desc": {"tr": "Dünya okyanusları geri dönüşü olmayan ekolojik çöküş eşiğinde!", "en": "The global ocean is on the brink of irreversible systemic collapse!", "ru": "Мировой океан на грани необратимого системного коллапса!"},

	# --- Coalition HQ & Biodiversity Indicators ---
	"hud.hq.title": {"tr": "KARARGAH: {region}", "en": "HEADQUARTERS: {region}", "ru": "ШТАБ: {region}"},
	"hud.hq.desc": {"tr": "Koalisyon komuta üssümüz ({region}). Bu bölgedeki kriz seviyesi %{limit} sınırına ulaşırsa operasyon kaybedilir! (Durum: %{integrity} Sağlam)", "en": "Our coalition command center ({region}). If this region's crisis reaches {limit}%, the mission is lost! (Status: {integrity}% Integrity)", "ru": "Командный центр коалиции ({region}). Если кризис здесь достигнет {limit}%, миссия провалена! (Целостность: {integrity}%)"},
	"hud.species.title": {"tr": "BİYOÇEŞİTLİLİK GÖSTERGELERİ", "en": "BIODIVERSITY INDICATORS", "ru": "ИНДИКАТОРЫ БИОРАЗНООБРАЗИЯ"},
	"hud.species.body": {
		"tr": "🐢 Deniz Kaplumbağası & Resif Türleri: Kirlilik azaldıkça ve deniz çayırları iyileştikçe çoğalır.\n🦭 Deniz Memelileri (Balina, Fok, Samur): Deniz Koruma Alanları (MPA) ile artar.",
		"en": "🐢 Sea Turtles & Reef Species: Grow as pollution drops and seagrass/coral habitats recover.\n🦭 Marine Mammals (Whales, Seals, Otters): Rebound with Marine Protected Areas (MPA).",
		"ru": "🐢 Морские черепахи и рифовые виды: растут при снижении загрязнения.\n🦭 Морские млекопитающие (киты, тюлени, каланы): растут с расширением заповедников."
	},
	"hud.species.turtle": {"tr": "Deniz Kaplumbağaları", "en": "Sea Turtles", "ru": "Морские черепахи"},
	"hud.species.turtle.desc": {"tr": "Küresel okyanuslardaki aktif kaplumbağa ve resif kolonileri.", "en": "Active sea turtle and reef indicator colonies across global oceans.", "ru": "Популяции морских черепах и рифовых видов в Мировом океане."},
	"hud.species.seal": {"tr": "Deniz Memelileri", "en": "Marine Mammals", "ru": "Морские млекопитающие"},
	"hud.species.seal.desc": {"tr": "Koruma altındaki balina, fok, dugong ve deniz samuru popülasyonu.", "en": "Protected whale, seal, dugong and sea otter populations.", "ru": "Охраняемые популяции китов, тюленей, дюгоней и каланов."},
	"hud.species.tip": {"tr": "Küresel okyanus biyoçeşitliliğini ve bayrak türlerin sağlığını temsil eder.", "en": "Reflects global ocean biodiversity and flagship species health.", "ru": "Отражает здоровье глобального биоразнообразия океанов."},

	# --- Global Ocean Summits ---
	"summit.modal.title": {"tr": "KÜRESEL OKYANUS ZİRVESİ", "en": "GLOBAL OCEAN SUMMIT", "ru": "ГЛОБАЛЬНЫЙ ОКЕАНИЧЕСКИЙ САММИТ"},
	"summit.status.success": {"tr": "HEDEF TUTTURULDU — DİPLOMATİK ZAFER", "en": "TARGET MET — DIPLOMATIC TRIUMPH", "ru": "ЦЕЛЬ ДОСТИГНУТА — ДИПЛОМАТИЧЕСКИЙ УСПЕХ"},
	"summit.status.warning": {"tr": "KRİZ EŞİĞİ AŞILDI — ZORUNLU DİPLOMASİ", "en": "CRISIS THRESHOLD BREACHED — URGENT CONCESSIONS", "ru": "ПОРОГ ПРЕВЫШЕН — СРОЧНЫЕ УСТУПКИ"},
	"toast.summit_resolved": {"tr": "Küresel Okyanus Zirvesi Kararı Yürürlüğe Girdi.", "en": "Global Ocean Summit Resolution Enacted.", "ru": "Резолюция Глобального океанического саммита вступила в силу."},
	"summit.2031.title": {"tr": "2031 Cenevre Küresel Okyanus Zirvesi", "en": "2031 Geneva Global Ocean Summit", "ru": "Женевский океанический саммит 2031"},
	"summit.2031.success.desc": {"tr": "Küresel Deniz Sağlığı hedefleri aştı. Üye ülkeler Cenevre Okyanus Paktı'nı tam destekle onayladı. Seçilecek fon paketi koalisyona tahsis edilecek:", "en": "Global Sea Health exceeded expectations. Member nations unanimously ratify the Geneva Ocean Pact. Select your bonus grant package:", "ru": "Здоровье Мирового океана превзошло ожидания. Страны одобрили Женевский пакт. Выберите пакет финансирования:"},
	"summit.2031.failure.desc": {"tr": "Deniz Sağlığı hedeflerin gerisinde kaldı. Kıyı devletleri finansmanı kesmekle tehdit ediyor. Acil taviz kararı alınması zorunludur:", "en": "Sea Health fell short of treaty milestones. Member states threaten funding cuts. Urgent concessions required:", "ru": "Здоровье моря отстает от целевых показателей. Государства грозят урезать бюджет. Требуются экстренные решения:"},
	"summit.2031.desc_pass": {"tr": "Küresel Deniz Sağlığı hedefleri aştı. Üye ülkeler Cenevre Okyanus Paktı'nı tam destekle onayladı. Seçilecek fon paketi koalisyona tahsis edilecek:", "en": "Global Sea Health exceeded expectations. Member nations unanimously ratify the Geneva Ocean Pact. Select your bonus grant package:", "ru": "Здоровье Мирового океана превзошло ожидания. Страны одобрили Женевский пакт. Выберите пакет финансирования:"},
	"summit.2031.desc_fail": {"tr": "Deniz Sağlığı hedeflerin gerisinde kaldı. Kıyı devletleri finansmanı kesmekle tehdit ediyor. Acil taviz kararı alınması zorunludur:", "en": "Sea Health fell short of treaty milestones. Member states threaten funding cuts. Urgent concessions required:", "ru": "Здоровье моря отстает от целевых показателей. Государства грозят урезать бюджет. Требуются экстренные решения:"},

	"summit.2036.title": {"tr": "2036 Lizbon Okyanus İlerleme Konferansı", "en": "2036 Lisbon Ocean Progress Conference", "ru": "Лиссабонская океаническая конференция 2036"},
	"summit.2036.success.desc": {"tr": "Plastik temizleme ve balıkçılık kotaları küresel takdir topladı. Yeni ileri teknoloji araştırma konsorsiyumu kuruluyor:", "en": "Ocean cleanup and fishing quotas earned global acclaim. An advanced marine tech consortium is formed:", "ru": "Очистка пластика и квоты вылова получили мировое признание. Создается консорциум передовых технологий:"},
	"summit.2036.failure.desc": {"tr": "Artan sıcaklık ve yaygın kirlilik nedeniyle diplomatik kriz patlak verdi. Koalisyon iç denetime alınıyor:", "en": "Rising sea heat and widespread contamination sparked a diplomatic dispute. The coalition faces audit penalties:", "ru": "Рост температур и загрязнение вызвали дипломатический кризис. Коалиция подверглась санкциям:"},
	"summit.2036.desc_pass": {"tr": "Plastik temizleme ve balıkçılık kotaları küresel takdir topladı. Yeni ileri teknoloji araştırma konsorsiyumu kuruluyor:", "en": "Ocean cleanup and fishing quotas earned global acclaim. An advanced marine tech consortium is formed:", "ru": "Очистка пластика и квоты вылова получили мировое признание. Создается консорциум передовых технологий:"},
	"summit.2036.desc_fail": {"tr": "Artan sıcaklık ve yaygın kirlilik nedeniyle diplomatik kriz patlak verdi. Koalisyon iç denetime alınıyor:", "en": "Rising sea heat and widespread contamination sparked a diplomatic dispute. The coalition faces audit penalties:", "ru": "Рост температур и загрязнение вызвали дипломатический кризис. Коалиция подверглась санкциям:"},

	"summit.2041.title": {"tr": "2041 Osaka Son Dönemeç Okyanus Zirvesi", "en": "2041 Osaka Final Horizon Summit", "ru": "Осакский саммит финального горизонта 2041"},
	"summit.2041.success.desc": {"tr": "2046 hedeflerine ramak kala dünya okyanusları yeniden canlanıyor. Liderler son büyük restorasyon paketini onaylıyor:", "en": "On the cusp of the 2046 deadline, global ocean ecology rebounds. World leaders sign the master restoration act:", "ru": "На пороге 2046 года Мировой океан возрождается. Лидеры подписывают генеральный пакт восстановления:"},
	"summit.2041.failure.desc": {"tr": "Kritik dönemeçte ekolojik çöküş riski hala devam ediyor. Olağanüstü hal fonları acil seferber edildi:", "en": "Severe collapse risks persist on the final stretch. Emergency contingency funds mobilized:", "ru": "Риски коллапса сохраняются на финишной прямой. Мобилизованы чрезвычайные резервы:"},
	"summit.2041.desc_pass": {"tr": "2046 hedeflerine ramak kala dünya okyanusları yeniden canlanıyor. Liderler son büyük restorasyon paketini onaylıyor:", "en": "On the cusp of the 2046 deadline, global ocean ecology rebounds. World leaders sign the master restoration act:", "ru": "На пороге 2046 года Мировой океан возрождается. Лидеры подписывают генеральный пакт восстановления:"},
	"summit.2041.desc_fail": {"tr": "Kritik dönemeçte ekolojik çöküş riski hala devam ediyor. Olağanüstü hal fonları acil seferber edildi:", "en": "Severe collapse risks persist on the final stretch. Emergency contingency funds mobilized:", "ru": "Риски коллапса сохраняются на финишной прямой. Мобилизованы чрезвычайные резервы:"},

	# Summit choice packages
	"summit.choice.grant_budget.title": {"tr": "Küresel Mavi Fon Hibesi", "en": "Global Blue Fund Grant", "ru": "Глобальный голубой грант"},
	"summit.choice.grant_budget.desc": {"tr": "+150 Bütçe koalisyon kasasına aktarılır.", "en": "+150 Budget added to the coalition treasury.", "ru": "+150 к бюджету коалиции."},
	"summit.choice.mandate_pol.title": {"tr": "Ortak Koruma Mandası", "en": "Joint Protection Mandate", "ru": "Мандат совместной защиты"},
	"summit.choice.mandate_pol.desc": {"tr": "+45 Politik Destek ve diplomatik güç sağlar.", "en": "+45 Political Support and diplomatic sway.", "ru": "+45 к политической поддержке."},
	"summit.choice.copernicus_sci.title": {"tr": "Küresel Okyanus Uydu Ağı", "en": "Global Ocean Satellite Network", "ru": "Глобальная сеть океанических спутников"},
	"summit.choice.copernicus_sci.desc": {"tr": "+50 Bilim Puanı ile teknoloji atılımı sağlar.", "en": "+50 Science Points for research breakthroughs.", "ru": "+50 к науке для прорывных исследований."},
	"summit.choice.lobby_concession.title": {"tr": "Sanayi Lobi Tavizi", "en": "Industrial Lobby Concession", "ru": "Уступка промышленному лобби"},
	"summit.choice.lobby_concession.desc": {"tr": "+40 Bütçe karşılığında -30 Politik Destek kaybı.", "en": "+40 Budget in exchange for -30 Political Support.", "ru": "+40 к бюджету ценой -30 к поддержке."},
	"summit.choice.fiscal_austerity.title": {"tr": "Mali Kemer Sıkma", "en": "Fiscal Austerity Program", "ru": "Программа жесткой экономии"},
	"summit.choice.fiscal_austerity.desc": {"tr": "-75 Bütçe kesintisi karşılığında +10 Politik Güven.", "en": "-75 Budget reduction, gaining +10 Political Support.", "ru": "-75 к бюджету в обмен на +10 к поддержке."},
	"summit.choice.emergency_pledge.title": {"tr": "Acil Bilim Seferberliği", "en": "Emergency Research Repurposing", "ru": "Экстренная мобилизация науки"},
	"summit.choice.emergency_pledge.desc": {"tr": "-35 Bilim Puanı harcanarak +20 Politik Destek sağlanır.", "en": "-35 Science repurposed to secure +20 Political Support.", "ru": "-35 к науке для получения +20 к поддержке."},
	"summit.btn.ratify": {"tr": "KARARI & TAAHHÜDÜ ONAYLA", "en": "RATIFY RESOLUTION & PLEDGE", "ru": "УТВЕРДИТЬ И ОБЯЗАТЬСЯ"},
	"news.summit_concluded": {"tr": "{year} Küresel Okyanus Zirvesi mutabakatla tamamlandı: Yeni koruma tedbirleri onaylandı.", "en": "{year} Global Ocean Summit concluded with consensus: New conservation pact ratified.", "ru": "Океанический саммит {year} года завершился консенсусом: Новый пакт утвержден."},
	"summit.report.title": {"tr": "5 YILLIK KARNE", "en": "5-YEAR REPORT CARD", "ru": "ОТЧЁТ ЗА 5 ЛЕТ"},
	"summit.grade.label": {"tr": "NOT: {g}", "en": "GRADE: {g}", "ru": "ОЦЕНКА: {g}"},
	"summit.grade.S": {"tr": "Olağanüstü Restorasyon", "en": "Exemplary Recovery", "ru": "Образцовое восстановление"},
	"summit.grade.A": {"tr": "Hedef Tutturuldu", "en": "Targets Achieved", "ru": "Цели достигнуты"},
	"summit.grade.B": {"tr": "Kırılgan Denge", "en": "Fragile Balance", "ru": "Хрупкий баланс"},
	"summit.grade.C": {"tr": "Kırmızı Alarm", "en": "Red Alert", "ru": "Красная тревога"},
	"summit.metric.health": {"tr": "Deniz Sağlığı", "en": "Sea Health", "ru": "Здоровье моря"},
	"summit.metric.temp": {"tr": "Isınma", "en": "Warming", "ru": "Потепление"},
	"summit.metric.spreads": {"tr": "5 Yıl Yayılım", "en": "5-Yr Spreads", "ru": "Распростр."},
	"summit.metric.bio": {"tr": "Biyoçeşitlilik", "en": "Biodiversity", "ru": "Биоразнообр."},
	"summit.metric.spread_fmt": {"tr": "{n} olay", "en": "{n} hits", "ru": "{n} сл."},
	"summit.trend.title": {"tr": "5 Yıllık Sağlık / Kriz Eğilimi", "en": "5-Year Health / Crisis Trend", "ru": "Тренд здоровья и кризиса (5 лет)"},
	"summit.pledge.header": {"tr": "5 Yıllık Taahhüt", "en": "5-Year Pledge", "ru": "Обязательство (5 лет)"},
	"summit.pledge.reward": {"tr": "Başarı: +80 Bütçe, +18 Destek", "en": "Success: +80 Budget, +18 Support", "ru": "Успех: +80 бюджет, +18 поддержка"},
	"summit.pledge.eval.pass": {"tr": "ÖNCEKİ TAAHHÜT TUTULDU: {name} (+80 Bütçe, +18 Destek)", "en": "PREVIOUS PLEDGE MET: {name} (+80 Budget, +18 Support)", "ru": "ОБЯЗАТЕЛЬСТВО ВЫПОЛНЕНО: {name} (+80 бюджет, +18 подд.)"},
	"summit.pledge.eval.fail": {"tr": "ÖNCEKİ TAAHHÜT KAÇIRILDI: {name} (-15 Destek)", "en": "PREVIOUS PLEDGE MISSED: {name} (-15 Support)", "ru": "ОБЯЗАТЕЛЬСТВО СОРВАНО: {name} (-15 поддержка)"},
	"summit.pledge.crisis.title": {"tr": "Kıyı Kalkanı Sözü", "en": "Coastal Shield Pledge", "ru": "Щит побережья"},
	"summit.pledge.crisis.target": {"tr": "Sonraki zirvede ort. krizi ≤ %{v} tut", "en": "Keep avg crisis ≤ {v}% by next summit", "ru": "Ср. кризис ≤ {v}% к саммиту"},
	"summit.pledge.health.title": {"tr": "Deniz Sağlığı Hedefi", "en": "Sea Health Mandate", "ru": "Цель здоровья моря"},
	"summit.pledge.health.target": {"tr": "Sonraki zirvede sağlığı ≥ %{v} yap", "en": "Reach Sea Health ≥ {v}% by next summit", "ru": "Здоровье моря ≥ {v}% к саммиту"},
	"summit.pledge.bio.title": {"tr": "Ekolojik Diriliş Sözü", "en": "Biodiversity Accord", "ru": "Пакт биоразнообразия"},
	"summit.pledge.bio.target": {"tr": "Ort. biyoçeşitliliği ≥ %{v} seviyesine çıkar", "en": "Lift avg biodiversity ≥ {v}%", "ru": "Биоразнообразие ≥ {v}% к саммиту"},

	# --- Interactive Spotlight Tutorial ---
	"tut.title": {"tr": "KÜRESEL HAREKAT REHBERİ", "en": "GLOBAL OPERATIONAL BRIEFING", "ru": "РУКОВОДСТВО ГЛОБАЛЬНОЙ ОПЕРАЦИИ"},
	"tut.step1.title": {"tr": "1. KARARGAH VE KÜRESEL KRİZ", "en": "1. HEADQUARTERS & GLOBAL CRISIS", "ru": "1. ШТАБ-КВАРТИРА И МИРОВОЙ КРИЗИС"},
	"tut.step1.body": {"tr": "Hoş geldin Komutan. Seçtiğiniz Karargah bölgesi Küresel Deniz Koalisyonu'nun ana üssüdür. Karargahın kriz seviyesi çöküş sınırını aşarsa operasyon derhal başarısız olur! Haritada bölgelere dokunarak kirlilik ve sıcaklık baskısını takip edin.", "en": "Welcome Commander. Your chosen Headquarters region is the Coalition's central base. If your HQ's crisis level crosses the collapse limit, the mission fails! Tap regions on the map to inspect pollution and warming drivers.", "ru": "Добро пожаловать, Командир. Выбранный регион — главный штаб коалиции. Если кризис там превысит лимит, миссия провалена! Нажимайте на регионы, чтобы следить за загрязнением."},
	"tut.step2.title": {"tr": "2. STRATEJİK KAYNAKLAR VE BALONCUKLAR", "en": "2. CORE RESOURCES & DATA BUBBLES", "ru": "2. РЕСУРСЫ И СФЕРЫ ДАННЫХ"},
	"tut.step2.body": {"tr": "Üst barda Bütçe, Politik Destek ve Bilim Puanı yer alır. Okyanus üzerinde beliren parlak veri baloncuklarına dokunarak fazladan Bilim ve Destek toplayabilirsiniz.", "en": "The top bar tracks Budget, Political Support, and Science Points. Tap glowing data bubbles floating on the ocean to collect bonus Science and Support.", "ru": "Вверху отображаются Бюджет, Поддержка и Наука. Нажимайте на светящиеся сферы над океаном, чтобы собирать науку и поддержку."},
	"tut.step3.title": {"tr": "3. YEREL SAHA OPERASYONLARI", "en": "3. LOCAL FIELD OPERATIONS", "ru": "3. ПОЛЕВЫЕ ОПЕРАЦИИ"},
	"tut.step3.body": {"tr": "Herhangi bir okyanus bölgesini seçtiğinizde bölge kartında 3 saha operasyonu açılır: Temizlik Operasyonu, Deniz Devriyesi ve Farkındalık Kampanyası. Deniz Devriyesi ve Farkındalık Kampanyası bölgenin kriz seviyesini doğrudan düşürür!", "en": "Selecting an ocean region opens 3 field operations: Cleanup Operation, Marine Patrol, and Awareness Campaign. Both Marine Patrol and Awareness Campaign directly reduce the region's crisis level!", "ru": "При выборе региона доступны 3 операции: Очистка, Морской патруль и Кампания осведомленности. Патруль и просвещение напрямую снижают уровень кризиса!"},
	"tut.step4.title": {"tr": "4. POLİTİKA AĞACI VE BİLİM SENTEZİ", "en": "4. POLICY TREE & SCIENCE SYNTHESIS", "ru": "4. ДРЕВО ПОЛИТИК И СИНТЕЗ"},
	"tut.step4.body": {"tr": "Sağ alt butona dokunarak Politika Ağacı'nı açın. Kalıcı altyapı, kanunlar ve deniz koruma alanları inşa edin. Kriz direnç geliştirirse Bilim Puanı ile Karşı-Aşı sentezleyin veya Biyo-Alg projeleri başlatın.", "en": "Tap the bottom-right button to open the Policy Tree. Build lasting infrastructure, fishing bans, and MPAs. If the crisis mutates, spend Science to synthesize counter-cures or launch bio-algae projects.", "ru": "Нажмите на кнопку справа внизу для открытия Древа политик. Стройте инфраструктуру, квоты и заповедники. При мутациях кризиса синтезируйте вакцины или запускайте био-проекты за науку."},
	"tut.step5.title": {"tr": "5. DEFCON ALARMI VE 2046 HEDEFİ", "en": "5. DEFCON BAROMETER & 2046 HORIZON", "ru": "5. БАРОМЕТР DEFCON И ГОРИЗОНТ 2046"},
	"tut.step5.body": {"tr": "DEFCON seviyesini 5-4 aralığında tutun. 2031, 2036 ve 2041'de Küresel Okyanus Zirveleri gerçekleşir. 2046'ya kadar Deniz Sağlığını %60'a ulaştırarak veya tüm krizleri %25'in altına çekerek okyanusları kurtarın!", "en": "Keep DEFCON status at 5 or 4. In 2031, 2036, and 2041, Global Ocean Summits convene. Reach 60% Sea Health or bring all regions below 25% crisis before 2046 to save the oceans!", "ru": "Держите DEFCON на уровне 5-4. В 2031, 2036 и 2041 пройдут Океанические саммиты. До 2046 года поднимите здоровье моря до 60% или опустите кризис ниже 25%, чтобы победить!"},
	"tut.btn.skip": {"tr": "Rehberi Kapat", "en": "Close Guide", "ru": "Закрыть"},
	"tut.btn.prev": {"tr": "← Önceki", "en": "← Previous", "ru": "← Назад"},
	"tut.btn.next": {"tr": "Sonraki →", "en": "Next →", "ru": "Далее →"},
	"tut.btn.start": {"tr": "HAREKATA BAŞLA", "en": "COMMENCE MISSION", "ru": "НАЧАТЬ ОПЕРАЦИЮ"},
	"hud.btn.help": {"tr": "Rehber", "en": "Guide", "ru": "Помощь"},
	"hud.btn.menu": {"tr": "☰ MENÜ", "en": "☰ MENU", "ru": "☰ МЕНЮ"},
	"hud.btn.mute_on": {"tr": "Sesi Aç", "en": "Unmute", "ru": "Вкл. звук"},
	"hud.btn.mute_off": {"tr": "Sesi Kapat", "en": "Mute", "ru": "Выкл. звук"},
	"hud.hq.integrity": {"tr": "Durum: %{val} Sağlam", "en": "Status: {val}% Integrity", "ru": "Целостность: {val}%"},

	# --- Auto-Save / Continue, 15 Global Achievements per Difficulty, Settings ---
	"ui.menu.continue": {"tr": "DEVAM ET ({year})", "en": "CONTINUE ({year})", "ru": "ПРОДОЛЖИТЬ ({year})"},
	"ui.menu.achievements": {"tr": "BAŞARIMLAR", "en": "ACHIEVEMENTS", "ru": "ДОСТИЖЕНИЯ"},
	"ui.menu.settings": {"tr": "AYARLAR", "en": "SETTINGS", "ru": "НАСТРОЙКИ"},
	"ui.settings.title": {"tr": "OYUN AYARLARI", "en": "GAME SETTINGS", "ru": "НАСТРОЙКИ ИГРЫ"},
	"ui.settings.graphics": {"tr": "GRAFİK KALİTESİ", "en": "GRAPHICS QUALITY", "ru": "КАЧЕСТВО ГРАФИКИ"},
	"ui.settings.gfx_low": {"tr": "Düşük (Maks. FPS)", "en": "Low (Max FPS)", "ru": "Низкое (Макс. FPS)"},
	"ui.settings.gfx_med": {"tr": "Orta (Dengeli)", "en": "Medium (Balanced)", "ru": "Среднее (Баланс)"},
	"ui.settings.gfx_high": {"tr": "Yüksek (Tam 3B)", "en": "High (Full 3D)", "ru": "Высокое (3D)"},
	"ui.settings.fps": {"tr": "FPS SABİTLEME", "en": "FPS LIMIT", "ru": "ЛИМИТ FPS"},
	"ui.settings.audio": {"tr": "SES SEVİYESİ", "en": "AUDIO VOLUME", "ru": "ГРОМКОСТЬ ЗВУКА"},
	"ui.settings.haptics": {"tr": "TİTREŞİM (HAPTİK)", "en": "VIBRATION (HAPTICS)", "ru": "ВИБРАЦИЯ"},
	"ui.settings.on": {"tr": "Açık", "en": "On", "ru": "Вкл"},
	"ui.settings.off": {"tr": "Kapalı", "en": "Off", "ru": "Выкл"},
	"ui.settings.lang": {"tr": "OYUN DİLİ", "en": "LANGUAGE", "ru": "ЯЗЫК ИГРЫ"},
	"ui.settings.close": {"tr": "KAYDET VE KAPAT", "en": "SAVE & CLOSE", "ru": "СОХРАНИТЬ И ЗАКРЫТЬ"},

	"ui.ach.modal_title": {"tr": "KÜRESEL OKYANUS BAŞARIMLARI", "en": "GLOBAL OCEAN ACHIEVEMENTS", "ru": "ГЛОБАЛЬНЫЕ ДОСТИЖЕНИЯ"},
	"ui.ach.subtitle": {"tr": "Her zorluk derecesi için 15 özel hedef (Toplam: {total}/45)", "en": "15 special goals for each difficulty level (Total: {total}/45)", "ru": "15 целей на каждом уровне сложности (Всего: {total}/45)"},
	"ui.ach.unlocked": {"tr": "✓ KAZANILDI", "en": "✓ UNLOCKED", "ru": "✓ ПОЛУЧЕНО"},
	"ui.ach.locked": {"tr": "KİLİTLİ", "en": "LOCKED", "ru": "ЗАКРЫТО"},
	"ui.ach.close": {"tr": "KAPAT", "en": "CLOSE", "ru": "ЗАКРЫТЬ"},

	"toast.game_resumed": {"tr": "Kayıtlı harekât yüklendi ({year} yılından devam ediliyor).", "en": "Saved mission loaded (resuming from {year}).", "ru": "Сохранение загружено ({year} г.)."},
	"toast.ach_unlocked": {"tr": "🏆 BAŞARIM KAZANILDI: {name}!", "en": "🏆 ACHIEVEMENT UNLOCKED: {name}!", "ru": "🏆 ДОСТИЖЕНИЕ ПОЛУЧЕНО: {name}!"},
	"ach.title": {"tr": "KAZANILAN BAŞARIMLAR", "en": "UNLOCKED ACHIEVEMENTS", "ru": "ПОЛУЧЕННЫЕ ДОСТИЖЕНИЯ"},

	# 15 Global Achievements (tracked per difficulty: Cadet, Commander, Admiral)
	"ach.north_atlantic_zero.name": {"tr": "Kuzey Atlantik Kalkanı", "en": "North Atlantic Shield", "ru": "Щит Северной Атлантики"},
	"ach.north_atlantic_zero.desc": {"tr": "Nasıl Kazanılır: Kuzey Atlantik bölgesinin kriz seviyesini %0'a indir.", "en": "How to Earn: Bring the North Atlantic's crisis level down to 0%.", "ru": "Как получить: Снизьте уровень кризиса в Северной Атлантике до 0%."},
	"ach.mediterranean_zero.name": {"tr": "İç Denizler Muhafızı", "en": "Inland Seas Guardian", "ru": "Страж Внутренних морей"},
	"ach.mediterranean_zero.desc": {"tr": "Nasıl Kazanılır: Akdeniz & Karadeniz bölgesinin kriz seviyesini %0'a indir.", "en": "How to Earn: Bring Mediterranean & Black Sea's crisis level down to 0%.", "ru": "Как получить: Снизьте уровень кризиса в Средиземном и Чёрном морях до 0%."},
	"ach.coral_triangle_zero.name": {"tr": "Mercan Üçgeni Kurtarıcısı", "en": "Coral Triangle Savior", "ru": "Спаситель Кораллового треугольника"},
	"ach.coral_triangle_zero.desc": {"tr": "Nasıl Kazanılır: Mercan Üçgeni bölgesinin kriz seviyesini %0'a indir.", "en": "How to Earn: Bring the Coral Triangle's crisis level down to 0%.", "ru": "Как получить: Снизьте уровень кризиса в Коралловом треугольнике до 0%."},
	"ach.arctic_zero.name": {"tr": "Kutup Yıldızı", "en": "Polar Star", "ru": "Полярная звезда"},
	"ach.arctic_zero.desc": {"tr": "Nasıl Kazanılır: Arktik Okyanusu'nun kriz seviyesini %0'a indir.", "en": "How to Earn: Bring the Arctic Ocean's crisis level down to 0%.", "ru": "Как получить: Снизьте уровень кризиса в Северном Ледовитом океане до 0%."},
	"ach.southern_zero.name": {"tr": "Antarktika Buz Kalkanı", "en": "Antarctic Ice Shield", "ru": "Антарктический щит"},
	"ach.southern_zero.desc": {"tr": "Nasıl Kazanılır: Güney Okyanusu'nun kriz seviyesini %0'a indir.", "en": "How to Earn: Bring the Southern Ocean's crisis level down to 0%.", "ru": "Как получить: Снизьте уровень кризиса в Южном океане до 0%."},
	"ach.east_asian_zero.name": {"tr": "Doğu Asya Dirilişi", "en": "East Asian Revival", "ru": "Возрождение Восточной Азии"},
	"ach.east_asian_zero.desc": {"tr": "Nasıl Kazanılır: Doğu Asya Denizleri'nin kriz seviyesini %0'a indir.", "en": "How to Earn: Bring the East Asian Seas' crisis level down to 0%.", "ru": "Как получить: Снизьте уровень кризиса в Восточноазиатских морях до 0%."},
	"ach.caribbean_zero.name": {"tr": "Karayip Mercan Barışı", "en": "Caribbean Reef Sanctuary", "ru": "Карибский заповедник"},
	"ach.caribbean_zero.desc": {"tr": "Nasıl Kazanılır: Karayipler & Meksika Körfezi'nin kriz seviyesini %0'a indir.", "en": "How to Earn: Bring Caribbean & Gulf of Mexico's crisis level down to 0%.", "ru": "Как получить: Снизьте уровень кризиса в Карибском бассейне до 0%."},
	"ach.south_pacific_zero.name": {"tr": "Büyük Set Resifi Muhafızı", "en": "Great Barrier Guardian", "ru": "Страж Большого Барьерного рифа"},
	"ach.south_pacific_zero.desc": {"tr": "Nasıl Kazanılır: Güney Pasifik & Büyük Set Resifi'nin kriz seviyesini %0'a indir.", "en": "How to Earn: Bring South Pacific & Great Barrier Reef's crisis level down to 0%.", "ru": "Как получить: Снизьте уровень кризиса в Южной Пацифике до 0%."},
	"ach.east_asian_clean.name": {"tr": "Plastik Akışı Avcısı", "en": "Plastic Surge Hunter", "ru": "Охотник за пластиком"},
	"ach.east_asian_clean.desc": {"tr": "Nasıl Kazanılır: Doğu Asya Denizleri'nde kirliliği %15'in altına düşür ve sağlığı %80+ yap.", "en": "How to Earn: Cut East Asian Seas pollution below 15% and reach 80%+ health.", "ru": "Как получить: Снизьте загрязнение Восточноазиатских морей ниже 15% и доведите здоровье до 80%+."},
	"ach.species_guardian.name": {"tr": "Bayrak Türlerin Koruyucusu", "en": "Biodiversity Guardian", "ru": "Хранитель биоразнообразия"},
	"ach.species_guardian.desc": {"tr": "Nasıl Kazanılır: Küresel bayrak tür göstergeleri toplamını 2.800 üzerine çıkar.", "en": "How to Earn: Reach 2,800+ combined global sea turtle and marine mammal indicators.", "ru": "Как получить: Доведите общее число индикаторов биоразнообразия до 2800+."},
	"ach.reformer.name": {"tr": "Mavi Reformcu", "en": "Blue Reformer", "ru": "Синий реформатор"},
	"ach.reformer.desc": {"tr": "Nasıl Kazanılır: Politika Ağacı'ndan en az 10 kalıcı çevre yasası kabul et.", "en": "How to Earn: Enact at least 10 permanent laws in the Policy Tree.", "ru": "Как получить: Примите не менее 10 законов в Древе политик."},
	"ach.full_shield.name": {"tr": "Demir Okyanus Kalkanı", "en": "Iron Ocean Shield", "ru": "Железный океанический щит"},
	"ach.full_shield.desc": {"tr": "Nasıl Kazanılır: Herhangi bir bölgede Koruma oranını %85 veya üzerine çıkar.", "en": "How to Earn: Raise Marine Protection to 85% or higher in any region.", "ru": "Как получить: Поднимите уровень защиты региона до 85% или выше."},
	"ach.high_awareness.name": {"tr": "Küresel Okyanus Bilinci", "en": "Global Ocean Consciousness", "ru": "Глобальное морское сознание"},
	"ach.high_awareness.desc": {"tr": "Nasıl Kazanılır: Tüm dünya okyanuslarında ortalama Halk Farkındalığını %75+ seviyesine ulaştır.", "en": "How to Earn: Reach 75%+ average Public Awareness across all ocean regions.", "ru": "Как получить: Достигните 75%+ средней осведомленности по всему океану."},
	"ach.cool_basin.name": {"tr": "İklim Dengeleyici", "en": "Climate Stabilizer", "ru": "Стабилизатор климата"},
	"ach.cool_basin.desc": {"tr": "Nasıl Kazanılır: Küresel ısınmayı +2.6°C'nin altında tutarak oyunu zaferle tamamla.", "en": "How to Earn: Win the campaign while keeping global warming at or below +2.6°C.", "ru": "Как получить: Победите в кампании, удержав потепление не выше +2.6°C."},
	"ach.basin_victor.name": {"tr": "Küresel Okyanus Zaferi", "en": "Global Ocean Victor", "ru": "Победитель Мирового океана"},
	"ach.basin_victor.desc": {"tr": "Nasıl Kazanılır: 2046 yılından önce dünya okyanuslarını kurtararak zafer kazan.", "en": "How to Earn: Win the mission and save the global ocean ecosystem.", "ru": "Как получить: Одержите победу и спасите экосистему Мирового океана."},

	"end.report.grade": {"tr": "EKOLOJİ KARNESİ: {grade}", "en": "ECOLOGY GRADE: {grade}", "ru": "ЭКО-ОЦЕНКА: {grade}"},
	"end.report.species": {"tr": "Biyoçeşitlilik: {t} 🐢 · {s} 🦭", "en": "Biodiversity: {t} 🐢 · {s} 🦭", "ru": "Биота: {t} 🐢 · {s} 🦭"},
	"end.report.policies": {"tr": "Kabul Edilen Yasa: {n} / 24", "en": "Policies Enacted: {n} / 24", "ru": "Принято законов: {n} / 24"},
	"end.report.chart": {"tr": "2026–2046 DENİZ SAĞLIĞI (YEŞİL) & KRİZ (KIRMIZI) SEYRİ", "en": "2026–2046 SEA HEALTH (GREEN) & CRISIS (RED) TRAJECTORY", "ru": "ДИНАМИКА ЗДОРОВЬЯ МОРЯ И КРИЗИСА (2026–2046)"},
	"fx.alert.tap": {"tr": "ACİL KRİZ — MÜDAHALE İÇİN DOKUN", "en": "CRITICAL — TAP TO INTERVENE", "ru": "КРИЗИС — НАЖМИТЕ"},

	# --- Boot Loading Screen & Emblem Subtitle ---
	"ui.loading.step1": {"tr": "Dil Paketleri ve Arayüz Hazırlanıyor...", "en": "Loading Language Packs & UI Theme...", "ru": "Загрузка языковых пакетов и интерфейса..."},
	"ui.loading.step2": {"tr": "Küresel Uydu Verileri ve 3B Okyanus Yükleniyor...", "en": "Loading Global Satellite & 3D Ocean Map...", "ru": "Загрузка спутниковых данных и 3D-океана..."},
	"ui.loading.step3": {"tr": "Ekosistem Simülasyonu ve Politika Ağacı Kuruluyor...", "en": "Initializing Ecosystem Simulation & Policy Tree...", "ru": "Инициализация симуляции и Древа политик..."},
	"ui.loading.step4": {"tr": "Küresel Okyanus Komuta Merkezi Hazır!", "en": "Global Ocean Command Center Ready!", "ru": "Глобальный командный центр готов!"},
	"game.emblem_subtitle": {"tr": "KÜRESEL OKYANUS EKOSİSTEM SAVUNMASI", "en": "GLOBAL OCEAN ECOSYSTEM DEFENSE", "ru": "ГЛОБАЛЬНАЯ ЗАЩИТА ЭКОСИСТЕМЫ ОКЕАНОВ"},

	# --- Simplified Region Bottom-Sheet ---
	"hud.region.problem_fmt": {"tr": "Ana Sorun: {trait}", "en": "Key Issue: {trait}", "ru": "Главная проблема: {trait}"},
	"hud.region.health_crisis_fmt": {"tr": "Deniz Sağlığı: %{health}  •  Kriz: %{crisis}", "en": "Sea Health: {health}%  •  Crisis: {crisis}%", "ru": "Здоровье: {health}%  •  Кризис: {crisis}%"},

	# --- 3-Step Visual Mobile Tutorial Carousel ---
	"tut3.title": {"tr": "NASIL OYNANIR?", "en": "HOW TO PLAY?", "ru": "КАК ИГРАТЬ?"},
	"tut3.slide1.title": {"tr": "1. HEDEFİN: OKYANUSLARI KURTAR", "en": "1. YOUR GOAL: SAVE THE OCEANS", "ru": "1. ВАША ЦЕЛЬ: СПАСТИ ОКЕАНЫ"},
	"tut3.slide1.body": {"tr": "Dünya okyanusları kirleniyor! Bölgelere dokun, kirlilik kaynağını gör ve 2046'ya kadar Deniz Sağlığını %60'ın üzerinde tut.", "en": "The global oceans are polluting! Tap regions to inspect the crisis source and keep Sea Health above 60% until 2046.", "ru": "Мировой океан загрязняется! Нажимайте на регионы и удерживайте здоровье моря выше 60% до 2046 года."},
	"tut3.slide2.title": {"tr": "2. BALONLARI PATLAT & KAYNAK TOPLA", "en": "2. POP BUBBLES & COLLECT RESOURCES", "ru": "2. СОБИРАЙТЕ СФЕРЫ И РЕСУРСЫ"},
	"tut3.slide2.body": {"tr": "Haritada çıkan Mavi (Bilim) ve Turuncu (Destek) balonlara parmağınla dokunarak puan topla.", "en": "Tap the Cyan (Science) and Amber (Support) bubbles appearing on the map with your finger to collect points.", "ru": "Нажимайте пальцем на Голубые (Наука) и Оранжевые (Поддержка) сферы на карте, чтобы собирать очки."},
	"tut3.slide3.title": {"tr": "3. POLİTİKA AĞACINI GELİŞTİR", "en": "3. UPGRADE THE POLICY TREE", "ru": "3. РАЗВИВАЙТЕ ДРЕВО ПОЛИТИК"},
	"tut3.slide3.body": {"tr": "Sağ alttaki 'Politika Ağacı' butonuna bas, topladığın puanlarla koruma ve temizlik teknolojilerini aç!", "en": "Tap the 'Policy Tree' button at the bottom-right and spend your points to unlock protection & cleanup technologies!", "ru": "Нажмите кнопку «Древо политик» справа внизу и открывайте технологии защиты и очистки океана!"},
	"tut3.btn.start": {"tr": "ANLADIM, BAŞLA!", "en": "GOT IT, START!", "ru": "ПОНЯТНО, НАЧАТЬ!"},
	"tut3.slide1.healthy": {"tr": "%75 HEDEF SAĞLIK", "en": "75% TARGET HEALTH", "ru": "75% ЦЕЛЬ ЗДОРОВЬЯ"},
	"tut3.slide1.crisis": {"tr": "KRİZİ ENGELLE!", "en": "PREVENT CRISIS!", "ru": "ПРЕДОТВРАТИТЕ КРИЗИС!"},
	"tut3.slide2.sci": {"tr": "+3 BİLİM PUANI", "en": "+3 SCIENCE POINTS", "ru": "+3 ОЧКА НАУКИ"},
	"tut3.slide2.tap": {"tr": "👆 PARMAĞINLA DOKUN", "en": "👆 TAP WITH FINGER", "ru": "👆 НАЖМИТЕ ПАЛЬЦЕМ"},
	"tut3.slide2.sup": {"tr": "+5 DESTEK PUANI", "en": "+5 SUPPORT POINTS", "ru": "+5 ОЧКОВ ПОДДЕРЖКИ"},
	"tut3.slide3.adopted": {"tr": "✓ AÇILDI", "en": "✓ ADOPTED", "ru": "✓ ОТКРЫТО"},
	"tut3.slide3.available": {"tr": "UYGUN", "en": "AVAILABLE", "ru": "ДОСТУПНО"},
	"tut3.slide3.locked": {"tr": "KİLİTLİ", "en": "LOCKED", "ru": "ЗАКРЫТО"},
	"tut3.slide3.tree_btn": {"tr": "POLİTİKA AĞACI", "en": "POLICY TREE", "ru": "ДРЕВО ПОЛИТИК"},
}
