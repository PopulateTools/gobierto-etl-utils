SELECT
  tenders.id,
  tenders.title,
  document_number,
  permalink,
  contract_statuses.text AS status,
  CASE process_types.text
    WHEN 'minor_contract' THEN true
    ELSE false
  END as minor_contract,
  contract_types.text AS contract_type,
  submission_date,
  open_proposals_date,
  number_of_batches,
  number_of_proposals,
  contractors.name AS contractor,
  contractors.id AS contractor_id,
  contractors_types.text AS contractor_type,
  contract_value,
  initial_amount,
  initial_amount_no_taxes,
  array_to_string(tenders.cpvs, ',') AS cpvs,
  process_types.text AS process_type,
  COALESCE(categories.id, 23) as category_id,
  COALESCE(categories.title, 'other') as category_title
  FROM tenders
  INNER JOIN (
    SELECT id, name, entity_type
    FROM public_entities
    WHERE dir3 = <DIR3>
    UNION
    SELECT descendants.id, descendants.name, descendants.entity_type
    FROM public_entities
    LEFT JOIN public_entities descendants ON descendants.root_id = public_entities.id
    WHERE public_entities.dir3 = <DIR3>
  ) contractors ON contractor_entity_id = contractors.id
  LEFT JOIN entity_types contractors_types ON contractors_types.id = contractors.entity_type
  LEFT JOIN contract_types ON contract_type = contract_types.id
  LEFT JOIN contract_statuses ON status = contract_statuses.id
  LEFT JOIN process_types ON tenders.process_type = process_types.id
  LEFT JOIN cpv_categorizations ON cpv_categorizations.cpv_division = tenders.cpvs_divisions[1]
  LEFT JOIN categories ON categories.id = cpv_categorizations.category_id
