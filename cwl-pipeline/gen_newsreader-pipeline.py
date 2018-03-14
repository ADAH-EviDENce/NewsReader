from nlppln import WorkflowGenerator

with WorkflowGenerator() as wf:

    # Directory with input txt files
    txt_dir = wf.add_inputs(txt_dir='Directory')

    ###TODO: NewsReader module steps

    # Directory with output naf files
    wf.add_outputs(ner_stats='', txt='')

    # Save CWL file
    wf.save('newsreader-pipeline.cwl')
