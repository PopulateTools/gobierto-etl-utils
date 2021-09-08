SELECT
  CASE process_types.text
    WHEN 'minor_contract' THEN contracts.id
    ELSE tenders.id
  END as id,
  contracts.title,
  contracts.permalink,
  contracts.batch_number,
  contracts.start_date,
  contracts.end_date,
  contracts.duration,
  assignees.name AS assignee,
  contract_statuses.text AS status,
  contracts.initial_amount,
  contracts.initial_amount_no_taxes,
  contracts.final_amount,
  contracts.final_amount_no_taxes,
  contractors.name AS contractor,
  contractors.id AS contractor_id,
  contractors_types.text AS contractor_type,
  contract_types.text AS contract_type,
  process_types.text AS process_type,
  CASE process_types.text
    WHEN 'minor_contract' THEN true
    ELSE false
  END as minor_contract,
  array_to_string(contracts.cpvs, ',') AS cpvs,
  COALESCE(categories.id, 23) as category_id,
  COALESCE(categories.title, 'other') as category_title,
  contracts.contract_award_published_at::date AS award_date,
  contracts.contract_formalized_published_at::date AS formalized_date,
  contracts.gobierto_start_date AS gobierto_start_date,
  tenders.open_proposals_date,
  tenders.submission_date,
  tenders.number_of_proposals,
  tenders.contract_value AS estimated_value
FROM
  contracts
  INNER JOIN (
    SELECT id, name, entity_type
    FROM public_entities
    WHERE dir3 = '<DIR3>'
    UNION
    SELECT descendants.id, descendants.name, descendants.entity_type
    FROM public_entities
    LEFT JOIN public_entities descendants ON descendants.root_id = public_entities.id
    WHERE public_entities.dir3 = '<DIR3>'
  ) contractors ON contractor_entity_id = contractors.id
  LEFT JOIN private_entities assignees ON assignee_entity_id = assignees.id
  LEFT JOIN entity_types contractors_types ON contractors_types.id = contractors.entity_type
  LEFT JOIN contract_types ON contract_type = contract_types.id
  LEFT JOIN contract_statuses ON status = contract_statuses.id
  LEFT JOIN tenders ON contracts.permalink = tenders.permalink
  LEFT JOIN process_types ON contracts.process_type = process_types.id
  LEFT JOIN cpv_categorizations ON cpv_categorizations.cpv_division = contracts.cpvs_divisions[1]
  LEFT JOIN categories ON categories.id = cpv_categorizations.category_id
