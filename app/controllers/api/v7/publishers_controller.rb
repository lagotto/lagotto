class Api::V7::PublishersController < Api::BaseController
  def index
    collection = Publisher.active
    collection = collection.query(params[:q]) if params[:q]
    collection = collection.where(member_id: params[:member_id]) if params[:member_id]

    if params[:registration_agency_id].present? && registration_agency = cached_registration_agency(params[:registration_agency_id])
      collection = collection.where(registration_agency_id: registration_agency.id)
      @registration_agency_group = collection.where(registration_agency_id: registration_agency.id).group(:registration_agency_id).count.first
    end

    if params[:member_id].present? && member = cached_member(params[:member_id])
      collection = collection.where(member_id: member.id)
      @member_group = collection.where(member_id: member.id).group(:member_id).count.first
    end

    if params[:ids].present?
      ids = params[:ids].split(",").map { |id| id.upcase }
      collection = collection.where(name: ids)
    end

    if params[:registration_agency_id].present? && registration_agency = cached_registration_agency(params[:registration_agency_id])
      @registration_agencies = { id: params[:registration_agency_id],
                                 title: registration_agency.title,
                                 count: collection.where(registration_agency_id: registration_agency.id).count }
    else
      registration_agencies = collection.where.not(registration_agency_id: nil).group(:registration_agency_id).count
      registration_agency_names = cached_registration_agency_names
      @registration_agencies = registration_agencies.map { |k,v| { id: registration_agency_names[k][:name], title: registration_agency_names[k][:title], count: v } }
    end

    if params[:member_id]
      @members = { id: params[:member_id],
                   title: params[:member_id],
                   count: collection.where(member_id: params[:member_id]).count }
    else
      members = collection.where.not(member_id: nil).group(:member_id).count
      @members = members.map { |k,v| { id: k, title: k, count: v } }
    end

    collection = collection.order(:title)

    per_page = params[:per_page] && (0..1000).include?(params[:per_page].to_i) ? params[:per_page].to_i : 1000
    page = params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1
    collection = collection.paginate(per_page: per_page,
                                     page: page)
    @publishers = collection.decorate
  end

  def show
    publisher = Publisher.active.where(name: params[:id]).first
    fail ActiveRecord::RecordNotFound unless publisher.present?

    @publisher = publisher.decorate
  end
end
