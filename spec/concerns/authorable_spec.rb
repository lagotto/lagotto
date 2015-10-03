require 'rails_helper'

describe Agent do
  describe "get_one_author" do
    it 'should return the author in CSL format' do
      author = "Alexander W. Zaranek"
      result = subject.get_one_author(author)
      expect(result).to eq("family"=>"Zaranek", "given"=>"Alexander W.")
    end

    it 'should handle authors with incomplete names' do
      author = "Zaranek"
      result = subject.get_one_author(author)
      expect(result).to eq("family"=>"Zaranek", "given"=>"")
    end

    it 'should handle author in comma-delimited format' do
      author = "Zaranek, Alexander W."
      result = subject.get_one_author(author, sep: ", ", reversed: true)
      expect(result).to eq("family"=>"Zaranek", "given"=>"Alexander W.")
    end
  end

  describe "get_one_hashed_author" do
    it 'should return the author in CSL format' do
      author = { "creatorName" => "Alexander W. Zaranek" }
      result = subject.get_one_hashed_author(author)
      expect(result).to eq("family"=>"Zaranek", "given"=>"Alexander W.")
    end

    it 'should handle authors with incomplete names' do
      author = { "creatorName" => "Zaranek" }
      result = subject.get_one_hashed_author(author)
      expect(result).to eq("given"=>"Zaranek")
    end

    it 'should handle author in comma-delimited format' do
      author = { "creatorName" => "Zaranek, Alexander W." }
      result = subject.get_one_hashed_author(author)
      expect(result).to eq("family"=>"Zaranek", "given"=>"Alexander W.")
    end

    it 'should handle ORCID identifiers' do
      author = { "creatorName" => "Moore, Jonathan",
                 "nameIdentifier" => "0000-0002-5486-0407" }
      result = subject.get_one_hashed_author(author)
      expect(result).to eq("family"=>"Moore", "given"=>"Jonathan", "id"=>"http://orcid.org/0000-0002-5486-0407")
    end
  end

  describe "get_authors" do
    it 'should return the authors in CSL format' do
      authors = ["Madeline P. Ball", "Alexander W. Zaranek"]
      result = subject.get_authors(authors)
      expect(result).to eq([{"family"=>"Ball", "given"=>"Madeline P."}, {"family"=>"Zaranek", "given"=>"Alexander W."}])
    end

    it 'should handle author in comma-delimited format' do
      authors = ["Ball, Madeline P.", "Zaranek, Alexander W."]
      result = subject.get_authors(authors, sep: ", ", reversed: true)
      expect(result).to eq([{"family"=>"Ball", "given"=>"Madeline P."}, {"family"=>"Zaranek", "given"=>"Alexander W."}])
    end
  end
end
