class HomeController < ApplicationController

  def index
    # binding.pry
    @user = params[:user]
    @tweet = get_random_tweet(@user)
    @tweet_keywords = get_tweet_keywords(@tweet)
    @keywords = chosen_keywords(@tweet_keywords)
    @gif_url = get_gifs_with_retry(@tweet_keywords)
  end


private

  def get_random_tweet(user)
    tweets = Twitter.user_timeline(user, language:'en')
    tweets.sample
  end

  def get_tweet_keywords(tweet)
    tweet_text = tweet.text.gsub(/http\S*\b|@\S*\b|\bRT:?\b|/,'')
    tweet_text_keywords = remove_stop_words(tweet_text)
  end

  def remove_stop_words(tweet_text)
    tweet_text_keywords=tweet_text.split.map do |word|
      word.downcase.gsub(/\W|\bmicropoetry\b|\b2nd\b|\bmakeripsum\b|\b3rd\b|\bt\b|\bs\b|\bjust\b|\bm\b|\bcan\b|\bget\b|\beven\b|\ba\b|\bmuch\b|\babout\b|\babove\b|\bafter\b|\bagain\b|\bagainst\b|\ball\b|\bam\b|\ban\b|\band\b|\bany\b|\bare\b|\baren't\b|\bas\b|\bat\b|\bbe\b|\bbecause\b|\bbeen\b|\bbefore\b|\bbeing\b|\bbelow\b|\bbetween\b|\bboth\b|\bbut\b|\bby\b|\bcan't\b|\bcannot\b|\bcould\b|\bcouldn't\b|\bdid\b|\bdidn't\b|\bdo\b|\bdoes\b|\bdoesn't\b|\bdoing\b|\bdon't\b|\bdown\b|\bduring\b|\beach\b|\bfew\b|\bfor\b|\bfrom\b|\bfurther\b|\bhad\b|\bhadn't\b|\bhas\b|\bhasn't\b|\bhave\b|\bhaven't\b|\bhaving\b|\bhe\b|\bhe'd\b|\bhe'll\b|\bhe's\b|\bher\b|\bhere\b|\bhere's\b|\bhers\b|\bherself\b|\bhim\b|\bhimself\b|\bhis\b|\bhow\b|\bhow's\b|\bi\b|\bi'd\b|\bi'll\b|\bi'm\b|\bi've\b|\bif\b|\bin\b|\binto\b|\bis\b|\bisn't\b|\bit\b|\bit's\b|\bits\b|\bitself\b|\blet's\b|\bme\b|\bmore\b|\bmost\b|\bmustn't\b|\bmy\b|\bmyself\b|\bno\b|\bnor\b|\bnot\b|\bof\b|\boff\b|\bon\b|\bonce\b|\bonly\b|\bor\b|\bother\b|\bought\b|\bour\b|\bours\b|\bourselves\b|\bout\b|\bover\b|\bown\b|\bsame\b|\bshan't\b|\bshe\b|\bshe'd\b|\bshe'll\b|\bshe's\b|\bshould\b|\bshouldn't\b|\bso\b|\bsome\b|\bsuch\b|\bthan\b|\bthat\b|\bthat's\b|\bthe\b|\btheir\b|\btheirs\b|\bthem\b|\bthemselves\b|\bthen\b|\bthere\b|\bthere's\b|\bthese\b|\bthey\b|\bthey'd\b|\bthey'll\b|\bthey're\b|\bthey've\b|\bthis\b|\bthose\b|\bthrough\b|\bto\b|\btoo\b|\bunder\b|\buntil\b|\bup\b|\bvery\b|\bwas\b|\bwasn't\b|\bwe\b|\bwe'd\b|\bwe'll\b|\bwe're\b|\bwe've\b|\bwere\b|\bweren't\b|\bwhat\b|\bwhat's\b|\bwhen\b|\bwhen's\b|\bwhere\b|\bwhere's\b|\bwhich\b|\bwhile\b|\bwho\b|\bwho's\b|\bwhom\b|\bwhy\b|\bwhy's\b|\bwith\b|\bwon't\b|\bwould\b|\bwouldn't\b|\byou\b|\byou'd\b|\byou'll\b|\byou're\b|\byou've\b|\byour\b|\byours\b|\byourself\b|\byourselves\b|\d/,"")
    end
    tweet_text_keywords.keep_if {|word| word !=""}
    return tweet_text_keywords
  end

  def get_gifs_with_retry(tweet_keywords)
    count = 0
    url = nil

    while count < 10 && url == nil
      url = get_gif_url(tweet_keywords)
      count += 1
    end
    return url

  end

  def chosen_keywords(tweet_keywords)
    keywords = tweet_keywords.sample(2)
  end

  def get_gif_url(tweet_keywords)
    keywords = chosen_keywords(tweet_keywords)
    giphy_url = get_giffy_url(keywords)
    get_gif_from_giffy(giphy_url)
  end

  def get_giffy_url(chosen_keywords)
    url_keywords =  chosen_keywords.join("-")
    "http://api.giphy.com/v1/gifs/search?q=#{url_keywords}&api_key=dc6zaTOxFJmzC&limit=5"
  end

  def get_gif_from_giffy(giphy_url)
    resp = Net::HTTP.get_response(URI.parse(giphy_url))
    buffer = resp.body
    result = JSON.parse(buffer)
    if result["data"] && result["data"][0]
      return result["data"][0]["images"]["original"]["url"]
    else
      return nil
    end 
  end


end

