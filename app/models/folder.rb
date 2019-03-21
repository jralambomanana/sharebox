##
# The folder model

class Folder < ApplicationRecord

  belongs_to :user

  has_many :assets, :dependent => :destroy
  
  has_many :folders, foreign_key: "parent_id", :dependent => :destroy
  
  has_many :shared_folders, :dependent=> :destroy

  has_many :satisfactions, :dependent=> :destroy
  
  acts_as_tree

  validates :name, presence: true

  extend ActsAsTree::TreeWalker
  
  ##
  # Return true is the folder is shared
  def shared?
    !self.shared_folders.empty?
  end

  ##
  # Return true if the folder is polled 
  def is_polled?
    #return true if Poll.where(id: self.poll_id).length != 0
    result = self.poll_id
    unless result
      result=false
    end
    puts("folder model - test if folder is polled - result is #{result}")
    return result
  end

  ##
  # Return true if at least a satisfaction answer has been recorded on the folder
  def has_satisfaction_answer?
    if Satisfaction.find_by_folder_id(self.id)
      return true 
    else 
      return false
    end
  end

  ##
  # Return true if the folder has got assets 
  def has_assets? 
    return true if Asset.find_by_folder_id(self.id)
  end

  ##
  # return true if we can find at least one subfolder, asset or share directly related to the folder
  def has_sub_asset_or_share? 
    if Asset.find_by_folder_id(self.id) || Folder.find_by_parent_id(self.id) || SharedFolder.find_by_folder_id(self.id)
      return true
    else
      return false
    end
  end

  # return all assets belonging to a folder (directly - ie its own assets, not the ones in its subfolders)<br>
  # inutile non - folder.assets donne le même résultat
  #def get_assets
  #  return Asset.where(folder_id: self.id)
  #end
  def is_root?
    self.parent_id.nil?
  end

  ##
  # Return all subfolders, assets and shares related to the folder, directly or indirectly<br>
  # works recursively
  def get_subs_assets_shares
    folders = Folder.where(parent_id: self.id)
    assets = Asset.where(folder_id: self.id)
    shared_folders = SharedFolder.where(folder_id: self.id)
    childrens = assets + folders + shared_folders

    folders.each do |c|
      if c.has_sub_asset_or_share?
        childrens += c.get_subs_assets_shares
      end
      puts ("end of search for subfolder "+c.name.to_s+ " number "+c.id.to_s)
    end
    
    return childrens
  end
  
  ##
  # returns all subfolders related to the folder, directly or indirectly
  def get_all_sub_folders
    subfolders=self.children
    self.children.each do |children_folder|
      if children_folder.children
        subfolders += children_folder.get_all_sub_folders
      end
    end
    return subfolders
  end
  
  ##
  # Fix user_id to i on all folder's children (assets, subfolders, subassets, shares, subshares)
  def children_give_to(i)
    if self.has_sub_asset_or_share?
      self.get_subs_assets_shares.each do |c|
        c.user_id = i
        c.save
      end
    end
  end
  
  ##
  # is the folder swarmed ?<br>
  # has the folder been created or dropped in a directory belonging to another private user ?
  def is_swarmed?
    self.ancestors.each do |a|
      return true if a.user_id != self.user_id
    end
    return false
  end
  
  ##
  # is the folder swarmed to the specified user ?
  def is_swarmed_to_user?(user)
    return false if user.has_ownership?(self)
    self.ancestors.each do |a|
      return true if a.user_id == user.id
    end
    return false
  end
  
  ##
  # is there a subfolder swarmed by another user ?
  def has_sub_swarmed?
    self.get_all_sub_folders.each do |s|
      return true if s.user_id != self.user_id
    end
    return false
  end
  
  ##
  # is the folder explicitely shared to the user ?<br>
  # by a share in the shared_folders table
  def is_shared_to_user?(user)
    return true if SharedFolder.find_by_share_user_id_and_folder_id(user.id, self.id)
  end

  ##
  # is there a subfolder swarmed by user given in argument ?
  def has_sub_swarmed_to_user?(user)
    return false if user.has_ownership?(self)
    self.get_all_sub_folders.each do |s|
      return true if s.user_id == user.id
    end
    return false  
  end
  
  ##
  # return a list of all metadatas for a given folder id
  # list["shares"] will contain a table with all share ids
  # list["satis"] will contain a table with all satisfaction ids
  # to be inserted in the folder 'lists' field
  # to decode when reading the folder record : ActiveSupport::JSON.decode(folder.lists)
  def calc_meta
    meta={}
    # all shares ids associated to the folder
    shares=SharedFolder.where(folder_id: self.id).select("id")
    tab=[]
    shares.each do |s|
      tab << s.id
    end
    meta["shares"]=tab
    # all satisfactions ids associated to the folder
    satisfactions=Satisfaction.where(folder_id: self.id).select("id")
    tab=[]
    satisfactions.each do |s|
      tab << s.id
    end
    meta["satis"]=tab
    ActiveSupport::JSON.encode(meta)
  end
  
  ##
  # return an empty metadata object (for folder creation)
  def initialize_meta
    meta={}
    meta["shares"]=[]
    meta["satis"]=[]
    ActiveSupport::JSON.encode(meta)
  end
  
  ##
  # decoding the meta for an interpretation as a json object
  def get_meta
    ActiveSupport::JSON.decode(self.lists)
  end
  
end
