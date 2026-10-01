"""Ten one-use offline policy cases. Does not execute MATLAB or build packages."""
import ast
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / 'docs/planning'
PIN = PLAN / 'F07_03_FINAL_CODE_HASHES.json'
RESULT = PLAN / 'F07_03_CASE_RESULTS.json'
POLICY = ROOT / 'OxygenReleaseSourcePolicy.json'
FIXTURES = PLAN / 'F07_03_FIXTURES.json'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def evaluate(policy, inventory, expected_hashes, trace):
    """Independent Python interpreter of the SAME JSON; not a MATLAB test."""
    files = policy['required_sources'] + [policy['optional_smoke_source']] + policy['retained_unverified_assets']
    trace.append({'action':'policy_consumed', 'schema':policy['schema'], 'file_count':len(files)})
    if len({p.lower() for p in files}) != len(files):
        return 'duplicate_destination'
    for edge in policy['dynamic_edges']:
        if not all(edge[k] in policy['required_sources'] for k in ('from','via','to')):
            return 'missing_dynamic_edge'
    for name in files:
        if not name or re.search(r'(^/|\\|:|(^|/)\.\.?(/|$)|//|/$)',name):
            trace.append({'action':'rejected_path', 'path':name})
            return 'unsafe_path'
        segments = name.lower().split('/')
        if (Path(name).suffix.lower() in policy['forbidden_extensions'] or
            any(p in {v.lower() for v in policy['forbidden_segments']} for p in segments) or
            name.lower() in {v.lower() for v in policy['forbidden_exact_paths']} or
            any(re.search(p,name,re.I) for p in policy['forbidden_path_patterns'])):
            trace.append({'action':'rejected_exclusion', 'path':name})
            return 'excluded'
        if name not in inventory:
            trace.append({'action':'missing_required_file', 'path':name})
            return 'missing_required'
        if inventory[name] != expected_hashes[name]:
            trace.append({'action':'source_hash_drift', 'path':name})
            return 'source_changed'
    trace.append({'action':'source_list_validated', 'package_creation':'not_invoked'})
    return 'accepted_manifest_only'


def static_gate(policy):
    packager = (ROOT/'createOxygenReleasePackage.m').read_text()
    helper = (ROOT/'getOxygenReleaseSourceList.m').read_text()
    # Check the actual caller, not just the harness's copy of the policy name.
    prepare = 'SourcePlan = getOxygenReleaseSourceList(ProjectRoot,Config.includeSmokeTest);'
    recheck = 'SourcePlan = getOxygenReleaseSourceList(ProjectRoot,Config.includeSmokeTest,SourcePlan);'
    create = 'mkdirIfMissing(ReleaseFolder);'
    assert packager.index(prepare) < packager.index(recheck) < packager.index(create)
    between = packager[packager.index(recheck)+len(recheck):packager.index(create)]
    assert not between.strip(), 'Work inserted after final validation'
    assert "policyName='OxygenReleaseSourcePolicy.json';" in helper
    assert 'Policy=jsondecode(fileread(policyPath));' in helper
    assert 'Sources=cellstr(string(Policy.required_sources(:)));' in helper
    for field in ['optional_smoke_source','retained_unverified_assets','forbidden_extensions',
                  'forbidden_segments','forbidden_path_patterns','forbidden_exact_paths','dynamic_edges']:
        assert 'Policy.'+field in helper, field
    assert 'checkSourcePath(ProjectRoot,name);' in helper
    assert "assert(isequaln(Plan,ExpectedPlan)" in helper
    assert not re.search(r'\b(?:mkdir|mkdirIfMissing|copyfile|zip)\s*\(',helper)
    assert packager.count('copyfile(')==1
    assert 'for FileIdx = 1:numel(SourcePlan.RelativePaths)' in packager
    assert 'RelativePath = SourcePlan.RelativePaths{FileIdx};' in packager
    assert 'copyfile(Source,Destination);' in packager
    assert not re.search(r'^Folders\s*=',packager,re.M) and 'releaseRootFiles' not in packager
    assert 'continue' not in packager
    planned=json.loads((PLAN/'F07_03_PROPOSED_SOURCE_MANIFEST.json').read_text())
    required={e['path'] for entries in planned['groups'].values() for e in entries}
    assert set(policy['required_sources']) == required | {'getOxygenReleaseSourceList.m','OxygenReleaseSourcePolicy.json','THIRD_PARTY_NOTICES.md'}
    assert len(planned['groups']['required_root_additions'])==16
    assert len(planned['groups']['required_helper_matlab_files'])==337
    assert policy['dynamic_edges']==[{'from':'helpers/runOxygenDynamicsMaster.m','via':'helpers/runLegacyAnalysisScript.m','to':'OxygenDynamics_Master.m'}]
    return {'same_policy_file':str(POLICY.relative_to(ROOT)), 'validation_before_creation':True,
            'hash_recheck_immediately_before_creation':True, 'copy_loop_uses_validated_list_only':True,
            'matlab_validator_executed':False, 'interpreter_equivalence_proven':False,
            'limit':'Static call-path/data-policy checks plus an independent Python policy interpreter; no MATLAB/copy/ZIP execution.'}


def main():
    if RESULT.exists():
        raise SystemExit('STOP: one-use result already exists; no retry')
    pins=json.loads(PIN.read_text())
    drift=[p for p,h in pins['files'].items() if sha(ROOT/p)!=h]
    if drift:
        raise SystemExit('STOP before evaluation: final hash mismatch '+str(drift))
    ast.parse(Path(__file__).read_text())
    policy=json.loads(POLICY.read_text())
    fixtures=json.loads(FIXTURES.read_text())
    summary={'schema':'F07-03.offline-manifest-evidence-1','pin_manifest_sha256':sha(PIN),
             'policy_sha256':sha(POLICY),'cases':[], 'static_gate':None,
             'evaluations_used':0,'package_directories_created':0,'source_files_copied':0,
             'archives_created':0,'matlab_launches':0,'adapter_violations':[]}
    # Restrict writes to this report; block any package-directory/process/network operations.
    def guard(event,args):
        blocked=event in ('os.mkdir','os.system','subprocess.Popen','os.fork','os.posix_spawn',
                         'socket.connect','socket.getaddrinfo','shutil.copyfile','os.rename','os.remove')
        if event=='open':
            path,mode,flags=args
            writing=(isinstance(mode,str) and any(c in mode for c in 'wax+')) or (flags & (os.O_WRONLY|os.O_RDWR|os.O_CREAT|os.O_TRUNC))
            blocked=bool(writing and Path(path).resolve()!=RESULT)
        if blocked:
            summary['adapter_violations'].append(event)
            raise RuntimeError('Excluded operation: '+event)
    sys.addaudithook(guard)
    def save(mode='w'):
        with RESULT.open(mode) as stream:
            json.dump(summary,stream,indent=2);stream.write('\n')
    save('x')
    try:
        summary['static_gate']=static_gate(policy)
    except Exception as exc:
        summary['static_failure']=type(exc).__name__+': '+str(exc)
        summary['cases']=[{'name':c['name'],'status':'untested'} for c in fixtures['cases']]
        save();raise SystemExit(1)
    # Sources are read-only hash facts; asset entries are SYNTHETIC existence/hash placeholders.
    # This gate neither reads uninspected asset contents nor clears them for distribution.
    source_names=policy['required_sources']+[policy['optional_smoke_source']]
    baseline={p:pins['files'][p] for p in source_names}
    baseline.update({p:'synthetic-unverified-asset-hash' for p in policy['retained_unverified_assets']})
    summary['unverified_assets_simulated_only']=policy['retained_unverified_assets']
    stopped=False
    for case in fixtures['cases']:
        if stopped:
            summary['cases'].append({'name':case['name'],'status':'untested'});continue
        summary['evaluations_used']+=1
        row={'name':case['name'],'status':'started','trace':[]};summary['cases'].append(row);save()
        data=copy.deepcopy(policy);inventory=dict(baseline)
        try:
            if case['mutation']=='remove':inventory.pop(case['path'])
            elif case['mutation']=='include':
                data['required_sources'].append(case['path']);inventory[case['path']]='synthetic-excluded'
            elif case['mutation']=='hash':inventory[case['path']]='synthetic-changed-hash'
            actual=evaluate(data,inventory,baseline,row['trace'])
            row.update(expected=case['expected'],actual=actual)
            assert actual==case['expected'], 'Unexpected policy outcome'
            assert not summary['adapter_violations']
            assert all(sha(ROOT/p)==h for p,h in pins['files'].items()), 'Pinned file drift'
            row['status']='pass'
        except Exception as exc:
            row.update(status='fail',error=type(exc).__name__+': '+str(exc));stopped=True
        save()
        print(case['name'],row['status'],row.get('actual',row.get('error')),flush=True)
    after={p:sha(ROOT/p) for p in pins['files']}
    summary['post_hashes']=after
    summary['hash_gate_passed']=after==pins['files']
    summary['passed']=sum(c['status']=='pass' for c in summary['cases'])
    summary['failed']=sum(c['status']=='fail' for c in summary['cases'])
    summary['untested']=sum(c['status']=='untested' for c in summary['cases'])
    save()
    if stopped or not summary['hash_gate_passed']:raise SystemExit(1)


if __name__=='__main__':main()
