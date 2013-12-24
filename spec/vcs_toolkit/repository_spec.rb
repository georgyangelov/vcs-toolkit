require 'spec_helper'

describe VCSToolkit::Repository do

  let(:object_store) { {} }
  let(:working_dir)  { {} }
  let(:staging_area) { {} }

  it 'has correct getters' do
    repo = VCSToolkit::Repository.new object_store, working_dir, staging_area: staging_area

    expect(repo.repository).to   be object_store
    expect(repo.working_dir).to  be working_dir
    expect(repo.staging_area).to be staging_area
  end

  it 'has a staging area that defaults to the working directory' do
    repo = VCSToolkit::Repository.new object_store, working_dir

    expect(repo.staging_area).to be working_dir
  end

end