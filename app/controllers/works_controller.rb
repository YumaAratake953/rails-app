class WorksController < ApplicationController

  #webに接続するためのライブラリ
  require "open-uri"
  #スクレイピングに使用するライブラリ
  require "nokogiri"
  require 'bundler/setup'
  require 'csv'
  require 'mechanize'
  
  def index
    User.destroy_all
    #スクレイピングを行うプログラムを呼び出す
    #shop1_scraping
    #shop2_scraping
    #shop3_scraping
  end

  def new 
    @work = Work.new
  end

  #お気に入り追加ボタンを押された商品をデータベースに追加するアクション
  def favorite_add
    logger.debug(params[:id])
    favorite = Favorite.new
    favorite.user_id = 1
    favorite.foods_id = params[:id]
    favorite.save
    #商品ページに戻す
    redirect_to params[:nowUrl], notice: "商品をお気に入りに追加しました"
  end

  def favorite_list
    @id_list = []
    @favorite_list = []
    @user_id = 1 #利用しているユーザのIDを格納(今は1)

    #ユーザIDに該当するデータの商品IDを配列に格納
    @id_list = Favorite.where(user_id: 1)

    #各データベースからお気に入り商品IDに該当する商品情報を配列に格納する
    @id_list.each do |f|
      @favorite_list += Shop.where(id: f.foods_id) if Shop.find_by(id: f.foods_id) != nil
      @favorite_list += Shop2.where(id: f.foods_id) if Shop2.find_by(id: f.foods_id) != nil
      @favorite_list += Shop3.where(id: f.foods_id) if Shop3.find_by(id: f.foods_id) != nil
    end

  end

  #商品一覧を表示するアクション
  def list
    #データベースを検索するための2次元配列
    @shop_list = [['鮮魚セット','海鮮セット','海鮮'],['鮭','さけ'],['かに','ガニ','えび','蟹','海老'],
    ['帆立','ホタテ'],['ウニ','うに','イカ','いか','タコ','たこ'],['貝','かい','牡蠣','むき身','かき','カキ','あさり','しじみ','あわび','サザエ','ハマグリ','はまぐり'],
    ['いくら','筋子','たらこ','数の子','白子'],['カツオ','かつお'],['鱈','タラ'],['秋刀魚','さんま','サンマ'],['ほや','ホヤ']]
    @search_list = []
   
    if params[:work] == "100" then  #"全ての商品"が選択された場合　　　
      @search_list += Shop.all
      @search_list += Shop2.all
      @search_list += Shop3.all
    else
      #特定の商品が選択された場合
      #postされた数字に該当する2次元配列の値を取得する
      @foods = @shop_list[params[:work].to_i] 
      #配列内の単語が含まれた商品情報をデータベースから取得する
      @foods.each do |f|
        @q = Shop.ransack(name_cont: f)
        @search_list += @q.result(distinct: true) 
        @q = Shop2.ransack(name_cont: f)
        @search_list += @q.result(distinct: true) 
        @q = Shop3.ransack(name_cont: f)
        @search_list += @q.result(distinct: true) 
      end
    end
    #同じ値が取得されていないか検査する
    @search_list.uniq!(&:name)
    #取り出した値に対してページングを行うための処理を行う
    @search_lists = Kaminari.paginate_array(@search_list).page(params[:page]).per(60)
  end

  #漁師さん直送市場からのスクレイピングを行うアクション
  def shop1_scraping
    #データベースをまとめて更新するため今のデータを全て消す
    Shop.destroy_all

    @name1 = []
    @price1 = []
    @url1 = []
    @image1 = []
    @comment1 = []
    #クレイピング対象のURL
    url = "https://umai.fish/%E5%95%86%E5%93%81%E4%B8%80%E8%A6%A7%E7%94%A3%E5%9C%B0%E5%84%AA%E5%85%88"
    #取得するhtml用charset
    charset = nil
    html = URI.open(url).read

    # Nokogiri で切り分け
    doc = Nokogiri::HTML.parse(html,nil,charset)

    #スクレイピングによって得られた各データを配列に格納する
    #商品名
    name = doc.search("p.li_text02")
    name.each do |n|
      @name1 << n.text
    end
    #値段
    price = doc.search("p.li_text03")
    price.each do |p|
      @price1 << p.text
    end
    #商品サイトURL
    url = doc.search("p.li_img03").children
    url.each do |u|
      @url1 << u.get_attribute('href')
    end
    #商品の詳細情報
    comment = doc.search("p.li_text04")
    comment.each do |c|
      @comment1 << c.text
    end

    #商品画像をファイルに保存する
    f = "https://umai.fish"
    image = doc.search("p.li_img01").children
    image.each do |i|
      @image1 << f + i.get_attribute('src')
    end

    
    #各配列をデータベースに格納する
    range = 0..@name1.length
    range.each do |n|
      shop1 = Shop.new
      shop1.name = @name1[n]
      num = @price1[n]
      shop1.price = num.delete("^0-9").to_i if num != nil   #値段の数字部分だけを抜き出す
      shop1.url = @url1[n]
      shop1.com = @comment1[n]
      
      #商品画像を入れるファイルを作る
      filename= "foods1_#{n}.jpeg"
      shop1.img = filename
      shop1.save
      
      #取得した商品画像をファイルに格納する
      if @image1[n] != nil
        File.open(filename,"wb") do |file|
          open(@image1[n]) do |img|
            file.write(img.read)
          end
        end
      end
    end

  end

  #ぎょれんからのスクレイピング
  def shop2_scraping
    Shop2.destroy_all
    
    @name2 = []
    @price2 = []
    @url2 = []
    @image2 = []
    #クレイピング対象のURL
    url = "https://www.gyoren.net/ic/item"
    #取得するhtml用charset
    charset = nil
    
    loop do
      sleep 1
      html = URI.open(url).read
      doc = Nokogiri::HTML.parse(html,nil,charset)
      
      
      url = doc.search("div.sysThumbnailImage").children
      url.each do |u|
        @url2 << u.get_attribute('href') if u.get_attribute('href') != nil
      end
      name = url.children
      name.each do |s|
        @name2 << s.get_attribute('alt')
      end
      price = doc.search("div.sysRetailPrice")
      price.each do |p|
        @price2 << p.text.delete("\n")
      end
      name.each do |i|
        @image2 << i.get_attribute('src')
      end


      range = 0..@name2.length
      range.each do |n|
        shop2 = Shop2.new
        shop2.name = @name2[n]
        num = @price2[n]
        shop2.price = num.delete("^0-9").to_i if num != nil
        shop2.url = @url2[n]
        filename= "foods2_#{n}.jpeg"
        shop2.img = filename
        shop2.save

        if @image2[n] != nil
          File.open(filename,"wb") do |file|
            open(@image2[n]) do |img|
              file.write(img.read)
            end
          end
        end
      end

      next_link = nil
      next_url = doc.search("li").children
      next_url.each do |u|
        next_link = u if u.text == '>'
      end

      break unless next_link
      next_href = next_link.attribute('href')
      url = "#{next_href}"
      
    end
  end

  #山内鮮魚店からのスクレイピング
  def shop3_scraping
    Shop3.destroy_all
    @name3 = []
    @price3 = []
    @url3 = []
    @image3 = []
    @comment3 = []
    #クレイピング対象のURL
    url = "https://www.yamauchi-f.com/fs/yamauchi/c/seisen/1/1"
    #取得するhtml用charset
    charset = nil

    
    loop do
      sleep 1
      html = URI.open(url).read
      doc = Nokogiri::HTML.parse(html,nil,charset)

      name = doc.search("h2.itemGroup")
      name.each do |n|
        @name3 << n.text
      end
      price = doc.search("span.itemPrice")
      price.each do |p|
        @price3 << p.text
      end
      url = doc.search("h2.itemGroup").children
      url.each do |u|
        @url3 << u.get_attribute('href')
      end
      image = doc.search("div.FS2_thumbnail_container.FS2_additional_image_detail_container").children.children
      image.each do |i|
        @image3 << i.get_attribute('src')
      end
      comment = doc.search("p.FS2_ItemShortComment")
      comment.each do |c|
        @comment3 << c.text
      end

      range = 0..@name3.length
      range.each do |n|
        shop3 = Shop3.new
        shop3.name = @name3[n]
        num = @price3[n]
        shop3.price = num.delete("^0-9").to_i if num != nil
        shop3.url = @url3[n]
        shop3.com = @comment3[n]
        filename= "foods3_#{n}.jpg"
        shop3.img = filename
        shop3.save

        if @image3[n] != nil
          File.open(filename,"wb") do |file|
            open(@image3[n]) do |img|
              file.write(img.read)
            end
          end
        end
      end

      next_link = doc.at_css('.FS2_pager_link_next')
      break unless next_link
      next_href = next_link.attribute('href')
      url = "#{next_href}"
      
    end
    
  end

end
