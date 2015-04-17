class Ngram
  def initialize(target, regex = / /)
    @target = target
    @regex  = regex
  end

  def ngrams(n)
    @target.split(@regex).each_cons(n).to_a
  end

  def unigrams
    ngrams(1)
  end

  def bigrams
    ngrams(2)
  end

  def trigrams
    ngrams(3)
  end
end

