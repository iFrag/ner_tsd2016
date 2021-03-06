package VectorEncoder;
use warnings;
use strict;
use utf8;
use open qw(:std :utf8);

# This package encodes and decodes between
# - a string
# - a 1-of-V vector
# - a dense probability vector
# in a given corpus.

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(label_2_vector get_label_vector_size label_2_int int_2_label);

our $DELIM = " "; 

our %nlabels = (
  'cnec1.0' => 87,
  'cnec1.1' => 87,
  'cnec2.0' => 95,
  'cnec2.0_konkol' => 17,
  'cnec1.1_konkol' => 17,
  'conll2003_en' => 11,
);

our %int2label = ( 
  'conll2003_en' => [ 'O', 'I', 'L',
            'B-LOC', 'U-LOC',
            'B-MISC', 'U-MISC',
            'B-ORG', 'U-ORG',
            'B-PER', 'U-PER',
          ],
  'cnec1.0' => [ 'O', 'I', 'L',
            'B-ps', 'U-ps',
            'B-pf', 'U-pf',
            'B-p_', 'U-p_',
            'B-pc', 'U-pc',
            'B-pp', 'U-pp',
            'B-pm', 'U-pm',
            'B-pd', 'U-pd', 
            'B-pb', 'U-pb',
            'B-gu', 'U-gu',
            'B-gc', 'U-gc',
            'B-gr', 'U-gr',
            'B-gs', 'U-gs',
            'B-gq', 'U-gq',
            'B-gh', 'U-gh',
            'B-gl', 'U-gl',
            'B-gt', 'U-gt',
            'B-g_', 'U-g_',
            'B-gp', 'U-gp',
            'B-ic', 'U-ic',
            'B-if', 'U-if',
            'B-io', 'U-io',
            'B-ia', 'U-ia',
            'B-i_', 'U-i_',
            'B-oa', 'U-oa',
            'B-op', 'U-op',
            'B-om', 'U-om',
            'B-oe', 'U-oe',
            'B-o_', 'U-o_',
            'B-or', 'U-or',
            'B-oc', 'U-oc',
            'B-th', 'U-th',
            'B-ty', 'U-ty',
            'B-tm', 'U-tm',
            'B-td', 'U-td',
            'B-ti', 'U-ti',
            'B-tf', 'U-tf',
            'B-mn', 'U-mn',
            'B-mt', 'U-mt',
            'B-mr', 'U-mr',
            'B-ah', 'U-ah',
            'B-at', 'U-at',
            'B-az', 'U-az',
          ],
  'cnec1.1' => [ 'O', 'I', 'L',
            'B-ps', 'U-ps',
            'B-pf', 'U-pf',
            'B-p_', 'U-p_',
            'B-pc', 'U-pc',
            'B-pp', 'U-pp',
            'B-pm', 'U-pm',
            'B-pd', 'U-pd', 
            'B-pb', 'U-pb',
            'B-gu', 'U-gu',
            'B-gc', 'U-gc',
            'B-gr', 'U-gr',
            'B-gs', 'U-gs',
            'B-gq', 'U-gq',
            'B-gh', 'U-gh',
            'B-gl', 'U-gl',
            'B-gt', 'U-gt',
            'B-g_', 'U-g_',
            'B-gp', 'U-gp',
            'B-ic', 'U-ic',
            'B-if', 'U-if',
            'B-io', 'U-io',
            'B-ia', 'U-ia',
            'B-i_', 'U-i_',
            'B-oa', 'U-oa',
            'B-op', 'U-op',
            'B-om', 'U-om',
            'B-oe', 'U-oe',
            'B-o_', 'U-o_',
            'B-or', 'U-or',
            'B-oc', 'U-oc',
            'B-th', 'U-th',
            'B-ty', 'U-ty',
            'B-tm', 'U-tm',
            'B-td', 'U-td',
            'B-ti', 'U-ti',
            'B-tf', 'U-tf',
            'B-mn', 'U-mn',
            'B-mt', 'U-mt',
            'B-mr', 'U-mr',
            'B-ah', 'U-ah',
            'B-at', 'U-at',
            'B-az', 'U-az',
          ],
  'cnec2.0' => [ 'O', 'I', 'L',
            'B-ah', 'U-ah',
            'B-at', 'U-at',
            'B-az', 'U-az',
            'B-g_', 'U-g_',
            'B-gc', 'U-gc',
            'B-gh', 'U-gh',
            'B-gl', 'U-gl',
            'B-gq', 'U-gq',
            'B-gr', 'U-gr',
            'B-gs', 'U-gs',
            'B-gt', 'U-gt',
            'B-gu', 'U-gu',
            'B-i_', 'U-i_',
            'B-ia', 'U-ia',
            'B-ic', 'U-ic',
            'B-if', 'U-if',
            'B-io', 'U-io',
            'B-me', 'U-me',
            'B-mi', 'U-mi',
            'B-mn', 'U-mn',
            'B-ms', 'U-ms',
            'B-n_', 'U-n_',
            'B-na', 'U-na',
            'B-nb', 'U-nb',
            'B-nc', 'U-nc',
            'B-ni', 'U-ni',
            'B-no', 'U-no',
            'B-ns', 'U-ns',
            'B-o_', 'U-o_',
            'B-oa', 'U-oa',
            'B-oe', 'U-oe',
            'B-om', 'U-om',
            'B-op', 'U-op',
            'B-or', 'U-or',
            'B-p_', 'U-p_',
            'B-pc', 'U-pc',
            'B-pd', 'U-pd',
            'B-pf', 'U-pf',
            'B-pm', 'U-pm',
            'B-pp', 'U-pp',
            'B-ps', 'U-ps',
            'B-td', 'U-td',
            'B-tf', 'U-tf',
            'B-th', 'U-th',
            'B-tm', 'U-tm',
            'B-ty', 'U-ty',
          ],
  'cnec2.0_konkol' => [ 'O', 'I', 'L',
                'B-A', 'B-G', 'B-I', 'B-M', 'B-O', 'B-P', 'B-T',
                'U-A', 'U-G', 'U-I', 'U-M', 'U-O', 'U-P', 'U-T',
          ],
  'cnec1.1_konkol' => [ 'O', 'I', 'L',
                'B-A', 'B-G', 'B-I', 'B-M', 'B-O', 'B-P', 'B-T',
                'U-A', 'U-G', 'U-I', 'U-M', 'U-O', 'U-P', 'U-T',
          ],
        );

our %label2int = ( 
  'conll2003_en' => { 'O' => 0, 'I' => 1, 'L' => 2,
            'B-LOC' => 3, 'U-LOC' => 4,
            'B-MISC' => 5, 'U-MISC' => 6,
            'B-ORG' => 7, 'U-ORG' => 8,
            'B-PER' => 9, 'U-PER' => 10,
          },
  'cnec1.0' => { 'O' => 0,
            'I' => 1,
            'L' => 2,
            'B-ps' => 3, 'U-ps' => 4,
            'B-pf' => 5, 'U-pf' => 6,
            'B-p_' => 7, 'U-p_' => 8,
            'B-pc' => 9, 'U-pc' => 10,
            'B-pp' => 11, 'U-pp' => 12,
            'B-pm' => 13, 'U-pm' => 14,
            'B-pd' => 15, 'U-pd' => 16, 
            'B-pb' => 17, 'U-pb' => 18,
            'B-gu' => 19, 'U-gu' => 20,
            'B-gc' => 21, 'U-gc' => 22,
            'B-gr' => 23, 'U-gr' => 24,
            'B-gs' => 25, 'U-gs' => 26,
            'B-gq' => 27, 'U-gq' => 28,
            'B-gh' => 29, 'U-gh' => 30,
            'B-gl' => 31, 'U-gl' => 32,
            'B-gt' => 33, 'U-gt' => 34,
            'B-g_' => 35, 'U-g_' => 36,
            'B-gp' => 37, 'U-gp' => 38,
            'B-ic' => 39, 'U-ic' => 40,
            'B-if' => 41, 'U-if' => 42,
            'B-io' => 43, 'U-io' => 44,
            'B-ia' => 45, 'U-ia' => 46,
            'B-i_' => 47, 'U-i_' => 48,
            'B-oa' => 49, 'U-oa' => 50,
            'B-op' => 51, 'U-op' => 52,
            'B-om' => 53, 'U-om' => 54,
            'B-oe' => 55, 'U-oe' => 56,
            'B-o_' => 57, 'U-o_' => 58,
            'B-or' => 59, 'U-or' => 60,
            'B-oc' => 61, 'U-oc' => 62,
            'B-th' => 63, 'U-th' => 64,
            'B-ty' => 65, 'U-ty' => 66,
            'B-tm' => 67, 'U-tm' => 68,
            'B-td' => 69, 'U-td' => 70,
            'B-ti' => 71, 'U-ti' => 72,
            'B-tf' => 73, 'U-tf' => 74,
            'B-mn' => 75, 'U-mn' => 76,
            'B-mt' => 77, 'U-mt' => 78,
            'B-mr' => 79, 'U-mr' => 80,
            'B-ah' => 81, 'U-ah' => 82,
            'B-at' => 83, 'U-at' => 84,
            'B-az' => 85, 'U-az' => 86,
          },
  'cnec1.1' => { 'O' => 0,
            'I' => 1,
            'L' => 2,
            'B-ps' => 3, 'U-ps' => 4,
            'B-pf' => 5, 'U-pf' => 6,
            'B-p_' => 7, 'U-p_' => 8,
            'B-pc' => 9, 'U-pc' => 10,
            'B-pp' => 11, 'U-pp' => 12,
            'B-pm' => 13, 'U-pm' => 14,
            'B-pd' => 15, 'U-pd' => 16, 
            'B-pb' => 17, 'U-pb' => 18,
            'B-gu' => 19, 'U-gu' => 20,
            'B-gc' => 21, 'U-gc' => 22,
            'B-gr' => 23, 'U-gr' => 24,
            'B-gs' => 25, 'U-gs' => 26,
            'B-gq' => 27, 'U-gq' => 28,
            'B-gh' => 29, 'U-gh' => 30,
            'B-gl' => 31, 'U-gl' => 32,
            'B-gt' => 33, 'U-gt' => 34,
            'B-g_' => 35, 'U-g_' => 36,
            'B-gp' => 37, 'U-gp' => 38,
            'B-ic' => 39, 'U-ic' => 40,
            'B-if' => 41, 'U-if' => 42,
            'B-io' => 43, 'U-io' => 44,
            'B-ia' => 45, 'U-ia' => 46,
            'B-i_' => 47, 'U-i_' => 48,
            'B-oa' => 49, 'U-oa' => 50,
            'B-op' => 51, 'U-op' => 52,
            'B-om' => 53, 'U-om' => 54,
            'B-oe' => 55, 'U-oe' => 56,
            'B-o_' => 57, 'U-o_' => 58,
            'B-or' => 59, 'U-or' => 60,
            'B-oc' => 61, 'U-oc' => 62,
            'B-th' => 63, 'U-th' => 64,
            'B-ty' => 65, 'U-ty' => 66,
            'B-tm' => 67, 'U-tm' => 68,
            'B-td' => 69, 'U-td' => 70,
            'B-ti' => 71, 'U-ti' => 72,
            'B-tf' => 73, 'U-tf' => 74,
            'B-mn' => 75, 'U-mn' => 76,
            'B-mt' => 77, 'U-mt' => 78,
            'B-mr' => 79, 'U-mr' => 80,
            'B-ah' => 81, 'U-ah' => 82,
            'B-at' => 83, 'U-at' => 84,
            'B-az' => 85, 'U-az' => 86,
          },
  'cnec2.0' => { 'O' => 0, 'I' => 1, 'L' => 2,
            'B-ah' => 3, 'U-ah' => 4,
            'B-at' => 5, 'U-at' => 6,
            'B-az' => 7, 'U-az' => 8,
            'B-g_' => 9, 'U-g_' => 10,
            'B-gc' => 11, 'U-gc' => 12,
            'B-gh' => 13, 'U-gh' => 14,
            'B-gl' => 15, 'U-gl' => 16,
            'B-gq' => 17, 'U-gq' => 18,
            'B-gr' => 19, 'U-gr' => 20,
            'B-gs' => 21, 'U-gs' => 22,
            'B-gt' => 23, 'U-gt' => 24,
            'B-gu' => 25, 'U-gu' => 26,
            'B-i_' => 27, 'U-i_' => 28,
            'B-ia' => 29, 'U-ia' => 30,
            'B-ic' => 31, 'U-ic' => 32,
            'B-if' => 33, 'U-if' => 34,
            'B-io' => 35, 'U-io' => 36,
            'B-me' => 37, 'U-me' => 38,
            'B-mi' => 39, 'U-mi' => 40,
            'B-mn' => 41, 'U-mn' => 42,
            'B-ms' => 43, 'U-ms' => 44,
            'B-n_' => 45, 'U-n_' => 46,
            'B-na' => 47, 'U-na' => 48,
            'B-nb' => 49, 'U-nb' => 50,
            'B-nc' => 51, 'U-nc' => 52,
            'B-ni' => 53, 'U-ni' => 54,
            'B-no' => 55, 'U-no' => 56,
            'B-ns' => 57, 'U-ns' => 58,
            'B-o_' => 59, 'U-o_' => 60,
            'B-oa' => 61, 'U-oa' => 62,
            'B-oe' => 63, 'U-oe' => 64,
            'B-om' => 65, 'U-om' => 66,
            'B-op' => 67, 'U-op' => 68,
            'B-or' => 69, 'U-or' => 70,
            'B-p_' => 71, 'U-p_' => 72,
            'B-pc' => 73, 'U-pc' => 74,
            'B-pd' => 75, 'U-pd' => 76,
            'B-pf' => 77, 'U-pf' => 78,
            'B-pm' => 79, 'U-pm' => 80,
            'B-pp' => 81, 'U-pp' => 82,
            'B-ps' => 83, 'U-ps' => 84,
            'B-td' => 85, 'U-td' => 86,
            'B-tf' => 87, 'U-tf' => 88,
            'B-th' => 89, 'U-th' => 90,
            'B-tm' => 91, 'U-tm' => 92,
            'B-ty' => 93, 'U-ty' => 94,
          },
  'cnec2.0_konkol' => { 'O' => 0, 'I' => 1, 'L' => 2,
                'B-A' => 3, 'B-G' => 4,
                'B-I' => 5, 'B-M' => 6,
                'B-O' => 7, 'B-P' => 8,
                'B-T' => 9, 'U-A' => 10,
                'U-G' => 11, 'U-I' => 12,
                'U-M' => 13, 'U-O' => 14,
                'U-P' => 15, 'U-T' => 16,
                'U' => 17,
          },
    'cnec1.1_konkol' => { 'O' => 0, 'I' => 1, 'L' => 2,
                'B-A' => 3, 'B-G' => 4,
                'B-I' => 5, 'B-M' => 6,
                'B-O' => 7, 'B-P' => 8,
                'B-T' => 9, 'U-A' => 10,
                'U-G' => 11, 'U-I' => 12,
                'U-M' => 13, 'U-O' => 14,
                'U-P' => 15, 'U-T' => 16,
                'U' => 17,
          },
        );


sub label_2_int {
  my ($corpus, $label) = @_;

  die "Unknown corpus \"$corpus\"\n." if not exists $label2int{$corpus};
  die "Unknown corpus \"$corpus\"\n." if not exists $nlabels{$corpus};
  die "Unknown label \"$label\"\n." if not exists $label2int{$corpus}{$label};

  return $label2int{$corpus}{$label};
}


sub label_2_vector {
  my ($corpus, $label) = @_;

  my @vector = (0) x $nlabels{$corpus};
  $vector[label_2_int($corpus,$label)] = 1;

  return join $DELIM, @vector;
}


sub get_label_vector_size {
  my ($corpus) = @_;

  die "Unknown corpus \"$corpus\"\n." if not exists $nlabels{$corpus};

  return $nlabels{$corpus};
}


sub int_2_label {
  my ($corpus, $int) = @_;

  die "Unknown corpus \"$corpus\"\n." if not exists $int2label{$corpus};

  return ${$int2label{$corpus}}[$int];
}

1;
