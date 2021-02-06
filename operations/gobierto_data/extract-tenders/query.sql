SELECT
  tenders.id,
  tenders.title,
  document_number,
  permalink,
  contract_statuses.text AS status,
  CASE process_types.text
    WHEN 'Contrato menor' THEN true
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
  END as category_title
  FROM tenders
  LEFT JOIN fiscal_entities contractors ON contractor_id = contractors.id
  LEFT JOIN entity_types contractors_types ON contractors_types.id = contractors.entity_type
  LEFT JOIN contract_types ON contract_type = contract_types.id
  LEFT JOIN contract_statuses ON status = contract_statuses.id
  LEFT JOIN process_types ON tenders.process_type = process_types.id
  LEFT JOIN cpv_categorizations ON cpv_categorizations.cpv_division = tenders.cpvs_divisions[1]
  LEFT JOIN categories ON categories.id = cpv_categorizations.category_id
WHERE contractors.custom_place_id = <PLACE_ID>
