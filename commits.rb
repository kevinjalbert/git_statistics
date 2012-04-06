class Commits < Hash

  attr_accessor :data_authors, :data_authors_email

  def initalize
    super
  end

  def authors
    author_list = []
    self.each do |key,value|
      if not author_list.include?(value[:author])
        author_list << value[:author]
      end
    end
    return author_list
  end

  def authors_email
    author_list = []
    self.each do |key,value|
      if not author_list.include?(value[:author_email])
        author_list << value[:author_email]
      end
    end
    return author_list
  end

  def authors_statistics(email)

    # Use email or not for authors
    if email
      type = "author_email"
      author_list = authors_email
    else
      type = "author"
      author_list = authors
    end

    # Initialize the stats hash
    stats = Hash.new
    author_list.each do |author|
      stats[author] = Hash.new
      stats[author][:commits] = 0
      stats[author][:insertions] = 0
      stats[author][:deletions] = 0
      stats[author][:creates] = 0
      stats[author][:deletes] = 0
      stats[author][:renames] = 0
      stats[author][:copies] = 0
    end

    # Collect the stats for each author
    self.each do |key,value|
      stats[value[:"#{type}"]][:commits] += 1
      stats[value[:"#{type}"]][:insertions] += value[:insertions]
      stats[value[:"#{type}"]][:deletions] += value[:deletions]
      stats[value[:"#{type}"]][:creates] += value[:creates]
      stats[value[:"#{type}"]][:deletes] += value[:deletes]
      stats[value[:"#{type}"]][:renames] += value[:renames]
      stats[value[:"#{type}"]][:copies] += value[:copies]
    end

    return stats
  end

  def author_top_n_type(email, type, n=0)
    n = 0 if n < 0

    if email
      data = @data_authors_email
    else
      data = @data_authors
    end

      return nil if not data.first[1].has_key?(:"#{type}")
      return data.sorted_hash {|a,b| b[1][:"#{type}"] <=> a[1][:"#{type}"]}.to_a[0..n-1]
  end

  def calculate_statistics(email)
    @data_authors_email = authors_statistics(true) if email
    @data_authors = authors_statistics(false) if not email
  end
end

class Hash
  def sorted_hash(&block)
    self.class[sort(&block)]
  end
end
