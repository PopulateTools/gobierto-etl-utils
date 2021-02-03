SELECT
  contracts.id,
  contracts.title,
  contracts.permalink,
  contracts.batch_number,
  contracts.start_date,
  contracts.end_date,
  contracts.duration,
  assignees.name AS assignee,
  assignees_types.text AS assignee_type,
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
    WHEN 'Contrato menor' THEN true
    ELSE false
  END as minor_contract,
  array_to_string(contracts.cpvs, ',') AS cpvs,
  categories.id as category_id,
  CASE categories.title
    WHEN 'agriculture' THEN 'Servicios agrícolas y forestales'
    WHEN 'architecture' THEN 'Arquitectura e ingeniería'
    WHEN 'audiovisual' THEN 'Audiovisual'
    WHEN 'catering' THEN 'Hostelería y restauración'
    WHEN 'construction' THEN 'Construcción y mantenimiento'
    WHEN 'culture' THEN 'Cultura y deporte'
    WHEN 'education' THEN 'Enseñanza y formación'
    WHEN 'electrical' THEN 'Equipos eléctricos y de iluminación'
    WHEN 'environment' THEN 'Medio ambiente'
    WHEN 'finance' THEN 'Servicios financieros y seguros'
    WHEN 'furniture' THEN 'Mobiliario'
    WHEN 'health' THEN 'Salud'
    WHEN 'industry' THEN 'Industria y maquinaria'
    WHEN 'legal' THEN 'Jurídico, contabilidad, mercadotecnia...'
    WHEN 'other' THEN 'Otros'
    WHEN 'print' THEN 'Impresión y material de oficina'
    WHEN 'security' THEN 'Seguridad'
    WHEN 'social_services' THEN 'Servicios sociales'
    WHEN 'software' THEN 'Consultoría y desarrollo de software, equipos y licencias'
    WHEN 'telecom' THEN 'Telecomunicaciones y correos'
    WHEN 'textile' THEN 'Textil'
    WHEN 'transportation' THEN 'Transporte'
  END as category_title,
  COALESCE(
    contracts.contract_award_published_at, contracts.contract_formalized_published_at, contracts.start_date
  )::date AS award_date,
  tenders.open_proposals_date,
  tenders.submission_date,
  tenders.number_of_proposals,
  tenders.contract_value AS estimated_value
FROM
  contracts
  LEFT JOIN fiscal_entities contractors ON contractor_id = contractors.id
  LEFT JOIN fiscal_entities assignees ON assignee_id = assignees.id
  LEFT JOIN entity_types contractors_types ON contractors_types.id = contractors.entity_type
  LEFT JOIN entity_types assignees_types ON assignees_types.id = assignees.entity_type
  LEFT JOIN contract_types ON contract_type = contract_types.id
  LEFT JOIN contract_statuses ON status = contract_statuses.id
  LEFT JOIN tenders ON contracts.permalink = tenders.permalink
  LEFT JOIN process_types ON contracts.process_type = process_types.id
  LEFT JOIN cpv_categorizations ON cpv_categorizations.cpv_division = contracts.cpvs_divisions[1]
  LEFT JOIN categories ON categories.id = cpv_categorizations.category_id
WHERE contractors.custom_place_id = <PLACE_ID>
