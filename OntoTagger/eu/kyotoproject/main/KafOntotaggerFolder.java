package eu.kyotoproject.main;

import eu.kyotoproject.kaf.KafSaxParser;
import eu.kyotoproject.kaf.KafSense;
import eu.kyotoproject.kaf.KafTerm;
import eu.kyotoproject.kaf.LP;
import eu.kyotoproject.util.Resources;
import eu.kyotoproject.util.Util;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;

/**
 * Created with IntelliJ IDEA.
 * User: kyoto
 * Date: 1/29/13
 * Time: 3:20 PM
 * To change this template use File | Settings | File Templates.
 */
public class KafOntotaggerFolder {

    static final String layer = "terms";
    static final String name = "vua-synset-ontotagger";
    static final String version = "1.0";

    static public void main (String[] args) {
        Resources resources = new Resources();
        String pathToKafFolder = "";
        String fileExtension = "";
        String pathToSynsetOntologyFile = "";
        String pathToSynsetBaseConceptFile = "";
        String pathToOntologyOntologyFile = "";
        String pathToRelationsFile = "";
        String format = "naf";

        for (int i = 0; i < args.length; i++) {
            String arg = args[i];
            if ((arg.equalsIgnoreCase("--input-folder")) && (args.length>(i+1))) {
                pathToKafFolder = args[i+1];
            }
            else if ((arg.equalsIgnoreCase("--extension")) && (args.length>(i+1))) {
                fileExtension = args[i+1];
            }
            else if ((arg.equalsIgnoreCase("--format")) && (args.length>(i+1))) {
                format = args[i+1];
            }
            else if ((arg.equalsIgnoreCase("--synset-ontology")) && (args.length>(i+1))) {
                pathToSynsetOntologyFile = args[i+1];
                resources.processSynsetOntologyFile(pathToSynsetOntologyFile);
            }
            else if ((arg.equalsIgnoreCase("--synset-baseconcept")) && (args.length>(i+1))) {
                pathToSynsetBaseConceptFile = args[i+1];
                resources.processSynsetBaseConceptFile(pathToSynsetBaseConceptFile);
            }
            else if ((arg.equalsIgnoreCase("--ontology-ontology")) && (args.length>(i+1))) {
                pathToOntologyOntologyFile = args[i+1];
                resources.processOntologyOntologyFile(pathToOntologyOntologyFile);
             //   System.out.println("ontologyOntologyMap = " + ontologyOntologyMap.size());
            }
            else if ((arg.equalsIgnoreCase("--relations")) && (args.length>(i+1))) {
                pathToRelationsFile = args[i+1];
                resources.processRelationsFile(pathToRelationsFile);
            }
        }
        KafSaxParser kafSaxParser = new KafSaxParser();
        ArrayList<String> kafFiles = Util.makeRecursiveFileListAll(pathToKafFolder, fileExtension);
        for (int f = 0; f < kafFiles.size(); f++) {
            String pathToKafFile =  kafFiles.get(f);
            //System.out.println("pathToKafFile = " + pathToKafFile);
            String strBeginDate = eu.kyotoproject.util.DateUtil.createTimestamp();
            String strEndDate = null;

            kafSaxParser.parseFile(pathToKafFile);
            for (int i = 0; i < kafSaxParser.getKafTerms().size(); i++) {
                KafTerm kafTerm = kafSaxParser.getKafTerms().get(i);
                for (int j = 0; j < kafTerm.getSenseTags().size(); j++) {
                    KafSense kafSense = kafTerm.getSenseTags().get(j);
                    if (resources.synsetBaseconceptMap.containsKey(kafSense.getSensecode())) {
                        ArrayList<String> targets = resources.synsetBaseconceptMap.get(kafSense.getSensecode());
                        for (int k = 0; k < targets.size(); k++) {
                            String s = targets.get(k);
                            String [] fields = s.split("\t");
                            if (fields.length==2) {
                                KafSense externalRef = new KafSense();
                                externalRef.setRefType("base-concept");
                                externalRef.setSensecode(fields[1]);
                                if (!fields[0].isEmpty()) {
                                    externalRef.setRefType(fields[0]);
                                }
                                kafSense.addChildren(externalRef);
                            }
                        }
                    }

                    if (resources.synsetOntologyMap.containsKey(kafSense.getSensecode())) {
                        ArrayList<String> targets = resources.synsetOntologyMap.get(kafSense.getSensecode());
                        for (int k = 0; k < targets.size(); k++) {
                            String s = targets.get(k);
                            String [] fields = s.split("\t");
                            if (fields.length==2) {
                                KafSense externalRef = new KafSense();
                                externalRef.setSensecode(fields[1]);
                                ArrayList<String> coveredClasses = new ArrayList<String>();
                                coveredClasses.add(externalRef.getSensecode());
                                if (!fields[0].isEmpty()) {
                                    externalRef.setRefType(fields[0]);
                                }
                                if (resources.relationArrayList.contains(externalRef.getRefType()) || resources.relationArrayList.size()==0) {
                                    if (resources.ontologyOntologyMap.containsKey(externalRef.getSensecode())) {
                                        resources.extendExternalReference(coveredClasses, externalRef);
                                    }
                                    kafSense.addChildren(externalRef);
                                }
                            }
                        }
                    }
                }
            }

            strEndDate = eu.kyotoproject.util.DateUtil.createTimestamp();
            String host = "";
            try {
                host = InetAddress.getLocalHost().getHostName();
            } catch (UnknownHostException e) {
                e.printStackTrace();
            }
            LP lp = new LP(name,version, strBeginDate, strBeginDate, strEndDate, host);
            kafSaxParser.getKafMetaData().addLayer(layer, lp);
            try {
                OutputStream fos = new FileOutputStream(pathToKafFile+".ont.kaf");
                if (format.equalsIgnoreCase("naf")) {
                    kafSaxParser.writeNafToStream(fos);
                }
                else if (format.equalsIgnoreCase("kaf")) {
                    kafSaxParser.writeKafToStream(fos);
                }
                fos.close();
            } catch (IOException e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
        }

    }



}
