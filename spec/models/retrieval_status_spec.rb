require 'spec_helper'

describe RetrievalStatus do

 it { should belong_to(:article) }
 it { should belong_to(:source) }
 it { should have_many(:retrieval_histories).dependent(:destroy) }

end

