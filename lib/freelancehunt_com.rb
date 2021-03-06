require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class FreelancehuntCom
  CURRENCIES = { 'руб.' => "руб.", "$" => '$', '&#8364;' => '€', "грн." => 'грн.' }
  CATEGORIES = {
    '.NET' => "Программирование",
    '1C' => "Программирование",
    "Assembly" => "Программирование",
    "Basic/Visual Basic" => "Программирование",
    'C#' => "Программирование",
    'C/C++' => "Программирование",
    "ColdFusion" => "Программирование",
    "CSS" => "Программирование",
    "CVS/SVN" => "Программирование",
    "Delphi/Pascal" => "Программирование",
    "FLEX" => "Программирование",
    "HTML/XHTML" => "Программирование",
    "J2ME" => "Программирование",
    "Java" => "Программирование",
    "Javascript" => "Создание сайтов",
    "Perl" => "Программирование",
    "PHP" => "Программирование",
    "Python" => "Программирование",
    "Ruby" => "Программирование",
    "Shell scripting" => "Программирование",
    "UML" => "Программирование",
    "XML" => "Программирование",
    "Веб-программирование" => "Разработка сайтов",
    "Взлом и защита ПО" => "Программирование",
    "Игровые приложения" => "Разработка игр",
    "Прикладное программирование" => "Программирование",
    "Приложения для мобильных систем" => "Программирование",
    "Системное программирование" => "Программирование",
    "Тестирование и QA" => "Программирование",
    
    "FoxPro" => "Архитектура/Инжиниринг",
    "IBM DB2" => "Программирование",
    "Informix" => "Программирование",
    "Interbase" => "Программирование",
    "Microsoft Access" => "Программирование",
    "Microsoft SQL" => "Программирование",
    "MySQL" => "Программирование",
    "Oracle" => "Программирование",
    "PostgreSQL" => "Программирование",
    "SQLite" => "Программирование",
    "SyBase" => "Программирование",
    "Базы данных" => "Программирование",

    "Flash" => "Флеш",
    "Архитектура и инжиниринг" => "Архитектура/Инжиниринг",
    "Баннеры" => "Дизайн",
    "Векторная графика" => "Полиграфия",
    "Визуализация и моделирование" => "3D Графика",
    "Дизайн интерфейсов" => "Дизайн",
    "Дизайн интерьеров" => "Дизайн",
    "Дизайн сайтов" => "Дизайн",
    "Иллюстрации и рисунки" => "Дизайн",
    "Ландшафтный дизайн" => "Дизайн",
    "Наружная реклама" => "Дизайн",
    "Пиксельная графика" => "Дизайн",
    "Полиграфический дизайн" => "Полиграфия",
    "Разработка логотипов" => "Дизайн",
    "Разработка фирменного стиля" => "Дизайн",
    "Трехмерная графика" => "3D Графика",
    "Фото" => "Фотография",


    "FreeBSD" => "Архитектура/Инжиниринг",
    "Linux" => "Архитектура/Инжиниринг",
    "Mac OS" => "Архитектура/Инжиниринг",
    "Palm OS" => "Архитектура/Инжиниринг",
    "Solaris" => "Архитектура/Инжиниринг",
    "Unix" => "Архитектура/Инжиниринг",
    "Windows" => "Архитектура/Инжиниринг",
    "Windows Mobile" => "Архитектура/Инжиниринг",

    "AJAX" => "Программирование",
    "CMS" => "Разработка сайтов",
    "E-коммерция" => "Разработка сайтов",
    "ERP" => "Консалтинг",
    "GIS" => "Прочее",
    "RUP" => "Прочее",
    "VoIP" => "Прочее",
    "Компьютерные сети" => "Прочее",



    "Администрирование систем" => "Архитектура/Инжиниринг",
    "Бизнес консультирование" => "Консалтинг",
    "Копирайтинг и креатив" => "Тексты",
    "Маркетинговые исследования" => "Реклама/Маркетинг",
    "Набор текстов" => "Тексты",
    "Написание статей" => "Тексты",
    "Наполнение сайта/форума" => "Тексты",
    "Настройка ПО/серверов" => "Архитектура/Инжиниринг",
    "Обучение" => "Прочее",
    "Перевод текстов" => "Переводы",
    "Продвижение сайтов (SEO)" => "Оптимизация (SEO)",
    "Проектирование" => "Прочее",
    "Разработка презентаций" => "Дизайн",
    "Разработка ТЗ" => "Прочее",

    "Создание сайта &laquo;под ключ&raquo;" => "Разработка сайтов",
    "Сопровождение сайтов" => "Прочее",
    "Управление проектами" => "Прочее",
    "Хостинг сайтов" => "Прочее",

    "Английский язык" => "Переводы",
    "Испанский язык" => "Переводы",
    "Итальянский язык" => "Переводы",

    "Немецкий язык" => "Прочее",
    "Французкий язык" => "Прочее",


    "Анимация" => "Анимация/Мультипликация",
    "Аудио/видео монтаж" => "Анимация/Мультипликация",
    "Музыка" => "Прочее",
    "Обработка аудио" => "Прочее",
    "Обработка видео" => "Прочее"


  }

  def self.desc
    'freelancehunt.com'
  end

  def self.latest
    # вообще ебаная верстка ! в ссылка в атрибуте title пишут двойные кавычки из-за чего парсинг стандартным методами невозможем - пляшем с бубном!
    doc = Hpricot(open('http://freelancehunt.com/project/list/'))
    resultset = []
    @inc=0
     (doc/"/html/body/div/div[3]/div[2]/div/table/tbody").each do |projects_table|
      #puts convert(doc.to_s)
      (projects_table/"tr").each do |project_row|
        @inc=@inc+1
        args = {}
        next if @inc>20
        #puts "INSPECT: " + convert((project_row/'td')[0].inner_html)
        td1 = (project_row/'td')[0].inner_html.gsub(/\r|\n|\t/," ").to_s
        desc = convert(td1.gsub(/^(.+?)title="/,'').gsub(/" class="bigger"(.+?)$/,''))   #.match("^(.+?)")[1]
        args[:desc] = "#{desc}<br>Технологии: #{convert(((project_row/"td")[0]/"div.smaller").inner_html)}"
        #puts "DESCRPTION: #{desc}"
        args[:url] = "http://" + self.desc + td1.match(/href=\"([^\"]+)\"/)[1].to_s
        args[:remote_id] = args[:url].match(/\/(\d+).html/)[1]
        args[:title] = convert(td1.to_s.match(/class="bigger">([^<]+)</)[1])
        args[:created_at] = Time.now
        budjet = ((project_row/"td")[1]/"span.cash").inner_html.match(/(\d+) /)
        
        if budjet != nil
          args[:budjet]=budjet[1].to_f
          args[:currency]= convert(((project_row/"td")[1]/"span.cash").inner_html).match(/(\&\#8364\;|\$|руб\.|грн\.)/i)[1]
        end
        begin
          categories = convert(((project_row/'td')[0]/"div.smaller").inner_html).split(', ').map{|it| it.chomp.strip}
          categories.each do |category|
            if CATEGORIES[category]
              args[:category_id] = DB["select id from categories where title ilike E'%#{CATEGORIES[category]}%'"].first[:id]
              break
            end
          end
        rescue
        end

        resultset << args
      end
    end
   resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('utf-8//IGNORE', 'windows-1251', s).to_s
  end
end
