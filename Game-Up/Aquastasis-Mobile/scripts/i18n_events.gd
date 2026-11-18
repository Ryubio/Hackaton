extends RefCounted
## String table (decision event cards: titles, texts, choice labels, result texts. Owner: content module (en), localization (tr/ru)) merged by the I18n autoload; never read directly by game code.
## Format: key -> {"tr": ..., "en": ..., "ru": ...}. Keys are unique across all tables.

const STRINGS := {
	# --- Gulf of Mexico / Caribbean Oil Spill ---
	"event.oil_spill.title": {"tr": "{region} Açıklarında Petrol Sızıntısı", "en": "Offshore Oil Spill in {region}", "ru": "Разлив нефти в регионе {region}"},
	"event.oil_spill.text": {"tr": "{region} açıklarındaki bir derin deniz sondaj platformu ve tanker hattında sızıntı meydana geldi. Ham petrol tabakası mercan resiflerine ve kıyılara doğru ilerliyor.", "en": "An offshore drilling rig and tanker line in {region} is leaking crude oil. The slick is drifting toward coral reefs and coastal habitats.", "ru": "На глубоководной платформе в регионе {region} произошла утечка нефти. Пятно движется к коралловым рифам и берегам."},
	"event.oil_spill.a.label": {"tr": "Bariyerler ve toplayıcı filolar konuşlandır", "en": "Deploy booms and skimmer fleets", "ru": "Установить боны и привлечь скиммеры"},
	"event.oil_spill.a.result": {"tr": "Petrolün büyük kısmı resiflere ulaşmadan temizlendi. {region}: kirlilik sadece +4, farkındalık +5.", "en": "Most of the oil was skimmed before hitting the reefs. {region}: pollution only +4, awareness +5.", "ru": "Большую часть нефти удалось собрать вовремя. {region}: загрязнение всего +4, осведомленность +5."},
	"event.oil_spill.b.label": {"tr": "Kendi kendine dağılmasını bekle", "en": "Let currents disperse it", "ru": "Позволить пятну рассеяться самому"},
	"event.oil_spill.b.result": {"tr": "Petrol sahile ve resiflere vurdu. {region}: kirlilik +14, balık stoku -8.", "en": "The slick washed ashore onto the reefs. {region}: pollution +14, fish stock -8.", "ru": "Мазут осел на берегах и рифах. {region}: загрязнение +14, запасы рыбы -8."},

	# --- Great Barrier Reef / South Pacific Bleaching ---
	"event.heatwave.title": {"tr": "{region} Mercan Ağarması Krizinde", "en": "Mass Coral Bleaching in {region}", "ru": "Обесцвечивание кораллов в {region}"},
	"event.heatwave.text": {"tr": "{region} sularında okyanus sıcaklığı rekor seviyeye ulaştı. Büyük Set Resifi ve çevresindeki mercan kolonileri kitlesel ağarma tehlikesiyle karşı karşıya.", "en": "Ocean temperatures in {region} hit record highs. The Great Barrier Reef and surrounding coral colonies face mass bleaching.", "ru": "Температура воды в {region} бьет рекорды. Большой Барьерный риф под угрозой массового обесцвечивания."},
	"event.heatwave.a.label": {"tr": "Soğutma bulutları ve koruma bölgesi ilan et", "en": "Deploy cloud brightening & closures", "ru": "Запустить охлаждение и закрыть зоны"},
	"event.heatwave.a.result": {"tr": "Hızlı önlemler resifleri korudu: 2 yıl boyunca tüm okyanuslarda mercan ısı hasarı yarıya indi. {region}: mercan sağlığı sadece -3.", "en": "Fast interventions shield the reefs: coral heat damage is halved globally for two years. {region}: coral health only -3.", "ru": "Быстрые меры защитили рифы: тепловой урон кораллам снижен вдвое на 2 года. {region}: здоровье кораллов всего -3."},
	"event.heatwave.b.label": {"tr": "Müdahale etme, geçmesini bekle", "en": "Ride it out", "ru": "Ничего не предпринимать"},
	"event.heatwave.b.result": {"tr": "Kitlesel mercan ağarması yaşandı. {region}: mercan sağlığı -12, deniz çayırları -6.", "en": "Mass coral bleaching occurs. {region}: coral health -12, seagrass -6.", "ru": "Массовое обесцвечивание рифов. {region}: здоровье кораллов -12, морские травы -6."},

	# --- Lobby pressure ---
	"event.lobby_pressure.title": {"tr": "Küresel Sanayi Lobisi Kapıda", "en": "Global Industry Lobby at the Door", "ru": "Давление промышленного лобби"},
	"event.lobby_pressure.text": {"tr": "Çok uluslu plastik ve deniz taşımacılığı lobileri yeni okyanus kurallarının dondurulmasını talep ediyor. İstihdam vadedip medyayla tehdit ediyorlar.", "en": "Multinational plastics and shipping lobbies demand a freeze on new ocean rules. They promise jobs and threaten headlines.", "ru": "Транснациональные лоббисты требуют заморозить экологические правила, угрожая скандалами в прессе."},
	"event.lobby_pressure.a.label": {"tr": "Geri adım atma", "en": "Stand firm", "ru": "Проявить твердость"},
	"event.lobby_pressure.a.result": {"tr": "Taviz vermedin ve dünya kamuoyu arkanda durdu: tüm bölgelerde farkındalık +5.", "en": "You held the line and the global public rallied: +5 awareness in every region.", "ru": "Вы устояли, и общество вас поддержало: +5 к осведомленности во всех регионах."},
	"event.lobby_pressure.b.label": {"tr": "'Gönüllü' taahhütleri kabul et", "en": "Accept a 'voluntary' deal", "ru": "Принять 'добровольное' соглашение"},
	"event.lobby_pressure.b.result": {"tr": "Sanayi +60 bütçe ödedi ancak taahhütler yetersiz kaldı: 4 yıl boyunca kaynak kirliliği +%20.", "en": "Industry pays +60 budget, but its voluntary pledges leak: source inflow +20% for four years.", "ru": "Бизнес выплатил +60 бюджета, но приток загрязнения вырос на 20% на 4 года."},

	# --- Greenwashing scandal ---
	"event.greenwashing.title": {"tr": "Yeşil Aklama Skandalı", "en": "Greenwashing Scandal", "ru": "Скандал с гринвошингом"},
	"event.greenwashing.text": {"tr": "Araştırmacı gazeteciler, bir koalisyon sponsoru şirketin 'temiz okyanus' reklamları yaparken açık denize kimyasal atık döktüğünü ortaya çıkardı.", "en": "Investigative reporters reveal that a coalition sponsor dumped chemical waste on the high seas while running 'blue ocean' ads.", "ru": "Журналисты выяснили, что спонсор коалиции тайком сливал отходы в океан под прикрытием эко-рекламы."},
	"event.greenwashing.a.label": {"tr": "İlişkileri kes ve denetim raporu yayımla", "en": "Cut ties and publish an audit", "ru": "Разорвать связи и опубликовать аудит"},
	"event.greenwashing.a.result": {"tr": "Şeffaflık güven tazeledi: +15 siyasi destek ve tüm bölgelerde +4 farkındalık.", "en": "Radical transparency pays off: +15 political support and +4 awareness in every region.", "ru": "Открытость оправдала себя: +15 к политической поддержке и +4 к осведомленности везде."},
	"event.greenwashing.b.label": {"tr": "Sessiz kal", "en": "Stay quiet", "ru": "Замять скандал"},
	"event.greenwashing.b.result": {"tr": "Haber haftalarca gündemde kaldı: -15 siyasi destek ve 3 yıl boyunca farkındalık %50 daha hızlı siliniyor.", "en": "The story runs for weeks: -15 political support, and awareness fades 50% faster for three years.", "ru": "Удар по репутации: -15 поддержки, а осведомленность падает на 50% быстрее в течение 3 лет."},

	# --- Southern Ocean Krill Harvesting ---
	"event.fishers_coop.title": {"tr": "{region} Kril Avcılığı Anlaşması", "en": "Krill Fishery Accord in {region}", "ru": "Соглашение по вылову криля в {region}"},
	"event.fishers_coop.text": {"tr": "{region} sularında faaliyet gösteren balıkçılık filoları, koalisyon sürdürülebilir ekipman geçişini finanse ederse kril avını sınırlamayı teklif ediyor.", "en": "Fishing fleets in {region} offer to cap krill harvesting around penguin colonies if the coalition funds sustainable gear transition.", "ru": "Рыболовные флотилии в регионе {region} согласны ограничить вылов криля, если коалиция профинансирует переход на щадящие снасти."},
	"event.fishers_coop.a.label": {"tr": "Dönüşüm fonunu onayla ve kota koy", "en": "Fund transition & cap krill catch", "ru": "Профинансировать переход и квоты"},
	"event.fishers_coop.a.result": {"tr": "Kril stokları ve penguen kolonileri korundu. {region}: balık stoku +8, 4 yıl boyunca küresel av baskısı %10 azaldı.", "en": "Krill stocks and penguin colonies rebound. {region}: fish stock +8, and fishing pressure falls 10% globally for four years.", "ru": "Запасы криля и колонии пингвинов защищены: в регионе {region} запасы рыбы +8, промысловое давление снизилось на 10% на 4 года."},
	"event.fishers_coop.b.label": {"tr": "Teklifi reddet", "en": "Decline the offer", "ru": "Отклонить предложение"},
	"event.fishers_coop.b.result": {"tr": "Endüstriyel filolar kril sürülerini aşırı avlamaya devam ediyor. {region}: balık stoku -5.", "en": "Industrial fleets continue heavy krill harvesting. {region}: fish stock -5.", "ru": "Флотилии продолжили истощать запасы криля. {region}: запасы рыбы -5."},

	# --- Arctic Ice Melt & Polar Shipping Surge ---
	"event.tourism_surge.title": {"tr": "{region} Buz Erimesi ve Kutup Rotası", "en": "Arctic Ice Melt & Polar Shipping in {region}", "ru": "Таяние льдов и полярный маршрут в {region}"},
	"event.tourism_surge.text": {"tr": "{region} buzullarının çekilmesiyle yeni kuzey deniz ticaret rotaları ve kutup kruvaziyer turları patlama yaptı. Gemi emisyonları ve gürültü kutup yaşamını tehdit ediyor.", "en": "Retreating sea ice in {region} has sparked a boom in polar shipping lanes and expedition cruises. Soot, noise and bilge waste threaten fragile habitats.", "ru": "Отступление льдов в регионе {region} вызвало бум арктического судоходства и круизов. Выбросы и шум угрожают полярной фауне."},
	"event.tourism_surge.a.label": {"tr": "Ağır yakıtı yasakla ve rotaları sınırla", "en": "Ban heavy fuel & restrict polar transits", "ru": "Запретить тяжелое топливо и ограничить рейсы"},
	"event.tourism_surge.a.result": {"tr": "Kutup koruma kuralları ekosistemi güvenceye aldı. {region}: deniz çayırları +4, kirlilik -4, farkındalık +4.", "en": "Polar code restrictions protect the ice edge. {region}: seagrass +4, pollution -4, awareness +4.", "ru": "Строгие квоты защитили полярные воды. {region}: морские травы +4, загрязнение -4, осведомленность +4."},
	"event.tourism_surge.b.label": {"tr": "Ticari geçişlere serbest izin ver", "en": "Keep polar shipping lanes open", "ru": "Не ограничивать транзитный поток"},
	"event.tourism_surge.b.result": {"tr": "Geçiş ücretleri +70 bütçe sağladı ancak kutup ekosistemi zarar gördü. {region}: deniz çayırları -10, kirlilik +8.", "en": "Transit fees bring +70 budget, but shipping damages polar habitats. {region}: seagrass -10, pollution +8.", "ru": "Доходы выросли на +70 бюджета, но судоходство нанесло урон экосистеме. {region}: морские травы -10, загрязнение +8."},

	# --- East Asian Plastic & Algal Outbreak ---
	"event.mucilage.title": {"tr": "{region} Plastik ve Alg Patlaması", "en": "Plastic & Algal Surge in {region}", "ru": "Наплыв пластика и водорослей в {region}"},
	"event.mucilage.text": {"tr": "Muson taşkınlarıyla taşınan plastik atıklar ve sıcak suyun tetiklediği zararlı alg patlaması {region} kıyılarını boğuyor.", "en": "Monsoon river plastic inflows combined with warm water have triggered a massive toxic algal and waste bloom across {region}.", "ru": "Потоки пластика из рек и аномальное тепло вызвали токсичное цветение водорослей в акватории {region}."},
	"event.mucilage.a.label": {"tr": "Nehir bariyerleri ve temizlik filoları sevk et", "en": "Deploy river barriers and skimmers", "ru": "Задействовать очистные барьеры и флот"},
	"event.mucilage.a.result": {"tr": "Ekipler yüzeydeki plastik ve alg tabakasını topladı. {region}: kirlilik -14.", "en": "Crews intercept the plastic and algal bloom at the surface. {region}: pollution -14.", "ru": "Поверхность очищена специальными судами. {region}: загрязнение -14."},
	"event.mucilage.b.label": {"tr": "Numune topla, müdahaleyi ertele", "en": "Sample it for research, act later", "ru": "Изучить феномен в лаборатории"},
	"event.mucilage.b.result": {"tr": "Bilim insanları +15 bilim elde etti ancak kirlilik yayıldı. {region}: kirlilik +6, balık stoku -6.", "en": "Scientists bank +15 science in samples while the bloom spreads. {region}: pollution +6, fish stock -6.", "ru": "Получено +15 очков науки, но загрязнение нанесло урон фауне. {region}: загрязнение +6, рыба -6."},

	# --- Great Pacific Garbage Patch & Dark Trawlers ---
	"event.foreign_trawlers.title": {"tr": "{region} Çöp Girdabı ve Hayalet Ağlar", "en": "Garbage Patch & Ghost Nets in {region}", "ru": "Мусорное пятно и сети-призраки в {region}"},
	"event.foreign_trawlers.text": {"tr": "Büyük Pasifik Çöp Girdabı çevresinde konum cihazlarını kapatmış kaçak troller {region} açıklarında devasa hayalet ağlar bırakarak deniz yaşamını talan ediyor.", "en": "Around the Great Pacific Garbage Patch in {region}, dark trawlers with transponders off are stripping marine life and abandoning mega-ghost nets.", "ru": "В районе Большого тихоокеанского мусорного пятна в {region} суда с отключенными маячками ведут хищнический лов и бросают сети."},
	"event.foreign_trawlers.a.label": {"tr": "Açık deniz devriye ve ağ toplama filosu gönder", "en": "Dispatch high-seas patrol & net recovery", "ru": "Выслать океанский патруль и тральщики сетей"},
	"event.foreign_trawlers.a.result": {"tr": "Devriye gemileri kaçak filoları uzaklaştırdı ve hayalet ağları topladı. {region}: koruma +10.", "en": "Patrol vessels intercept the trawlers and haul up ghost nets. {region}: protection +10.", "ru": "Патруль выдворил нарушителей и поднял сети. {region}: уровень защиты +10."},
	"event.foreign_trawlers.b.label": {"tr": "Diplomatik nota gönder", "en": "Send a diplomatic protest", "ru": "Ограничиться дипломатической нотой"},
	"event.foreign_trawlers.b.result": {"tr": "Notalar yazılırken hayalet ağlar ekosistemi biçti. {region}: balık stoku -15, deniz çayırları -5.", "en": "While notes are exchanged, ghost nets devastate marine life. {region}: fish stock -15, seagrass -5.", "ru": "Пока велась переписка, траулеры опустошили воды. {region}: запасы рыбы -15, морские травы -5."},

	# --- Flagship species breeding season ---
	"event.caretta_nesting.title": {"tr": "{region} Bayrak Tür Üreme Sezonu", "en": "Flagship Species Breeding in {region}", "ru": "Сезон размножения редких видов в {region}"},
	"event.caretta_nesting.text": {"tr": "Nesli tehlike altındaki deniz kaplumbağaları ve deniz memelileri {region} kıyılarında üreme ve yuvalama dönemine girdi, ancak kıyı ışıklandırması ve tekne trafiği onları tehdit ediyor.", "en": "Endangered sea turtles and marine mammals are gathering along the coasts of {region} for breeding season, right next to busy ports and coastal lights.", "ru": "Редкие морские черепахи и млекопитающие выходят к берегам {region} для размножения рядом с шумными портами и огнями побережья."},
	"event.caretta_nesting.a.label": {"tr": "Kıyı koruma kordonu oluştur", "en": "Enforce coastal sanctuary buffer", "ru": "Взять побережье под круглосуточную охрану"},
	"event.caretta_nesting.a.result": {"tr": "Gönüllüler ve korucular üreme alanlarını güvenceye aldı. {region}: farkındalık +8, koruma +6.", "en": "Rangers and volunteers protect the breeding grounds. {region}: awareness +8, protection +6.", "ru": "Волонтеры защитили места размножения. {region}: осведомленность +8, защита +6."},
	"event.caretta_nesting.b.label": {"tr": "Kıyı ticaretini kısıtlama", "en": "Keep coastal zones unrestricted", "ru": "Не ограничивать береговой бизнес"},
	"event.caretta_nesting.b.result": {"tr": "Kıyı işletmeleri +30 bütçe kazandırdı ancak yavrular zarar gördü. {region}: farkındalık -5.", "en": "Coastal commerce earns +30 budget, but lights and noise harm offspring. {region}: awareness -5.", "ru": "Прибрежный бизнес принес +30 бюджета, но шум и огни навредили молодняку. {region}: осведомленность -5."},

	# --- Global Ocean Summit 2031 ---
	"event.summit_2031.title": {"tr": "Küresel Okyanus Zirvesi: 2031 (Cenevre)", "en": "Global Ocean Summit: 2031 (Geneva)", "ru": "Глобальный океанический саммит: 2031 (Женева)"},
	"event.summit_2031.text": {"tr": "Görev başlangıcından beş yıl sonra Küresel Deniz Koalisyonu Cenevre'de okyanus taahhütlerini gözden geçiriyor. Delegeler ve bağışçılar izliyor.", "en": "Five years into the mission, the Global Marine Coalition meets in Geneva to review its ocean pledges. Donors and delegates are watching.", "ru": "Спустя 5 лет после старта миссии лидеры встречаются в Женеве для оценки выполнения океанических соглашений."},
	"event.summit_2031.a.label": {"tr": "Bağlayıcı küresel plastik sözleşmesini geçir", "en": "Push a binding global plastics pact", "ru": "Принять строгий глобальный пакт по пластику"},
	"event.summit_2031.a.result": {"tr": "Sözleşme kabul edildi: bir sonraki zirveye kadar tüm okyanuslarda kirlilik girdisi -%20 azaldı.", "en": "The pact passes: source inflow -20% globally until the next summit.", "ru": "Пакт принят: сброс отходов снижен на 20% во всех океанах до следующего саммита."},
	"event.summit_2031.b.label": {"tr": "Bağışçı hibesini al", "en": "Take the donor grant", "ru": "Взять гранты инвесторов"},
	"event.summit_2031.b.result": {"tr": "Bağışçılar +100 bütçe sağladı. Plastik sözleşmesi şimdilik rafa kaldırıldı.", "en": "Donors release +100 budget. The plastics pact is shelved for now.", "ru": "Получено +100 к бюджету. Соглашение по пластику отложено."},

	# --- Global Ocean Summit 2036 ---
	"event.summit_2036.title": {"tr": "Küresel Okyanus Zirvesi: 2036 (Lizbon)", "en": "Global Ocean Summit: 2036 (Lisbon)", "ru": "Глобальный океанический саммит: 2036 (Лиссабон)"},
	"event.summit_2036.text": {"tr": "2046 hedefine giden yolun yarısında Lizbon'da toplanan delegeler, yeni açık deniz koruma alanları ile iklim finansmanı arasında seçim yapıyor.", "en": "Halfway to 2046 in Lisbon. Delegates are split between new high-seas marine reserves and a fresh round of climate finance.", "ru": "Половина пути до 2046 года в Лиссабоне. Дебаты между расширением заповедников и получением нового транша."},
	"event.summit_2036.a.label": {"tr": "Açık deniz koruma alanlarını genişlet", "en": "Expand high-seas protected areas", "ru": "Расширить морские заповедники"},
	"event.summit_2036.a.result": {"tr": "Tüm okyanuslarda yeni rezervler ilan edildi: her bölgede koruma +10.", "en": "New reserves are declared across the oceans: +10 protection in every region.", "ru": "Объявлены новые охраняемые зоны: +10 к защите во всех регионах."},
	"event.summit_2036.b.label": {"tr": "İklim fonunu kasaya aktar", "en": "Bank the climate finance", "ru": "Принять финансовую помощь"},
	"event.summit_2036.b.result": {"tr": "Fondan +80 bütçe ve +10 siyasi destek alındı ancak yeni koruma alanı açılmadı.", "en": "The fund pays out +80 budget and +10 political support, but no new reserves.", "ru": "Фонд выделил +80 бюджета и +10 поддержки, но новые заповедники не созданы."},

	# --- Global Ocean Summit 2041 ---
	"event.summit_2041.title": {"tr": "Küresel Okyanus Zirvesi: 2041 (Osaka)", "en": "Global Ocean Summit: 2041 (Osaka)", "ru": "Финальный океанический саммит: 2041 (Осака)"},
	"event.summit_2041.text": {"tr": "Hedefe son beş yıl kala Osaka'da toplanan dünya liderleri, okyanus koalisyonundan emisyonlar konusunda son bir kararlı hamle bekliyor.", "en": "Five years left in Osaka. The world asks the Global Marine Coalition for one last decisive push on emissions.", "ru": "Осталось всего 5 лет. На саммите в Осаке мир ждет от коалиции решительных мер по сокращению выбросов."},
	"event.summit_2041.a.label": {"tr": "Hızlı karbon sınırlaması uygula", "en": "Fast-track a carbon cap", "ru": "Ввести жесткий углеродный лимит"},
	"event.summit_2041.a.result": {"tr": "Sözleşme imzalandı: ısınma hemen 0.05°C düştü ve 2046'ya kadar %40 yavaşladı.", "en": "The cap is signed: warming drops by 0.05°C now and slows by 40% until 2046.", "ru": "Пакт подписан: потепление сразу снизилось на 0.05°C и замедлилось на 40% до 2046 года."},
	"event.summit_2041.b.label": {"tr": "Ekonomik büyümeyi öncelik yap", "en": "Put growth first", "ru": "Поставить во главу рост экономики"},
	"event.summit_2041.b.result": {"tr": "2046'ya kadar bütçe geliri +%20 arttı ancak küresel ısınma %10 hızlandı.", "en": "Budget income +20% until 2046, but warming speeds up by 10%.", "ru": "Доходы бюджета +20% до 2046 года, но потепление ускорилось на 10%."},
}
